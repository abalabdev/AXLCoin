//  Copyright (c) 2011-present, Facebook, Inc.  All rights reserved.
//  This source code is licensed under both the GPLv2 (found in the
//  COPYING file in the root directory) and Apache 2.0 License
//  (found in the LICENSE.Apache file in the root directory).

#ifndef ROCKSDB_LITE

#ifndef __STDC_FORMAT_MACROS
#define __STDC_FORMAT_MACROS
#endif

#include "utilities/transactions/transaction_test.h"
#include "utilities/transactions/write_unprepared_txn.h"
#include "utilities/transactions/write_unprepared_txn_db.h"

namespace rocksdb {

class WriteUnpreparedTransactionTestBase : public TransactionTestBase {
 public:
  WriteUnpreparedTransactionTestBase(bool use_stackable_db,
                                     bool two_write_queue,
                                     TxnDBWritePolicy write_policy)
      : TransactionTestBase(use_stackable_db, two_write_queue, write_policy){}
};

class WriteUnpreparedTransactionTest
    : public WriteUnpreparedTransactionTestBase,
      virtual public ::testing::WithParamInterface<
          std::tuple<bool, bool, TxnDBWritePolicy>> {
 public:
  WriteUnpreparedTransactionTest()
      : WriteUnpreparedTransactionTestBase(std::get<0>(GetParam()),
                                           std::get<1>(GetParam()),
                                           std::get<2>(GetParam())){}
};

INSTANTIATE_TEST_CASE_P(
    WriteUnpreparedTransactionTest, WriteUnpreparedTransactionTest,
    ::testing::Values(std::make_tuple(false, false, WRITE_UNPREPARED),
                      std::make_tuple(false, true, WRITE_UNPREPARED)));

TEST_P(WriteUnpreparedTransactionTest, ReadYourOwnWrite) {
  auto verify_state = [](Iterator* iter, const std::string& key,
                         const std::string& value) {
    ASSERT_TRUE(iter->Valid());
    ASSERT_OK(iter->status());
    ASSERT_EQ(key, iter->key().ToString());
    ASSERT_EQ(value, iter->value().ToString());
  };

  options.disable_auto_compactions = true;
  ReOpen();

  // The following tests checks whether reading your own write for
  // a transaction works for write unprepared, when there are uncommitted
  // values written into DB.
  //
  // Although the values written by DB::Put are technically committed, we add
  // their seq num to unprep_seqs_ to pretend that they were written into DB
  // as part of an unprepared batch, and then check if they are visible to the
  // transaction.
  auto snapshot0 = db->GetSnapshot();
  ASSERT_OK(db->Put(WriteOptions(), "a", "v1"));
  ASSERT_OK(db->Put(WriteOptions(), "b", "v2"));
  auto snapshot2 = db->GetSnapshot();
  ASSERT_OK(db->Put(WriteOptions(), "a", "v3"));
  ASSERT_OK(db->Put(WriteOptions(), "b", "v4"));
  auto snapshot4 = db->GetSnapshot();
  ASSERT_OK(db->Put(WriteOptions(), "a", "v5"));
  ASSERT_OK(db->Put(WriteOptions(), "b", "v6"));
  auto snapshot6 = db->GetSnapshot();
  ASSERT_OK(db->Put(WriteOptions(), "a", "v7"));
  ASSERT_OK(db->Put(WriteOptions(), "b", "v8"));
  auto snapshot8 = db->GetSnapshot();

  TransactionOptions txn_options;
  WriteOptions write_options;
  Transaction* txn = db->BeginTransaction(write_options, txn_options);
  WriteUnpreparedTxn* wup_txn = dynamic_cast<WriteUnpreparedTxn*>(txn);

  ReadOptions roptions;
  roptions.snapshot = snapshot0;

  auto iter = txn->GetIterator(roptions);

  // Test Get().
  std::string value;
  wup_txn->unprep_seqs_[snapshot2->GetSequenceNumber() + 1] =
      snapshot4->GetSequenceNumber() - snapshot2->GetSequenceNumber();

  ASSERT_OK(txn->Get(roptions, Slice("a"), &value));
  ASSERT_EQ(value, "v3");

  ASSERT_OK(txn->Get(roptions, Slice("b"), &value));
  ASSERT_EQ(value, "v4");

  wup_txn->unprep_seqs_[snapshot6->GetSequenceNumber() + 1] =
      snapshot8->GetSequenceNumber() - snapshot6->GetSequenceNumber();

  ASSERT_OK(txn->Get(roptions, Slice("a"), &value));
  ASSERT_EQ(value, "v7");

  ASSERT_OK(txn->Get(roptions, Slice("b"), &value));
  ASSERT_EQ(value, "v8");

  wup_txn->unprep_seqs_.clear();

  // Test Next().
  wup_txn->unprep_seqs_[snapshot2->GetSequenceNumber() + 1] =
      snapshot4->GetSequenceNumber() - snapshot2->GetSequenceNumber();

  iter->Seek("a");
  verify_state(iter, "a", "v3");

  iter->Next();
  verify_state(iter, "b", "v4");

  iter->SeekToFirst();
  verify_state(iter, "a", "v3");

  iter->Next();
  verify_state(iter, "b", "v4");

  wup_txn->unprep_seqs_[snapshot6->GetSequenceNumber() + 1] =
      snapshot8->GetSequenceNumber() - snapshot6->GetSequenceNumber();

  iter->Seek("a");
  verify_state(iter, "a", "v7");

  iter->Next();
  verify_state(iter, "b", "v8");

  iter->SeekToFirst();
  verify_state(iter, "a", "v7");

  iter->Next();
  verify_state(iter, "b", "v8");

  wup_txn->unprep_seqs_.clear();

  // Test Prev(). For Prev(), we need to adjust the snapshot to match what is
  // possible in WriteUnpreparedTxn.
  //
  // Because of row locks and ValidateSnapshot, there cannot be any committed
  // entries after snapshot, but before the first prepared key.
  delete iter;
  roptions.snapshot = snapshot2;
  iter = txn->GetIterator(roptions);
  wup_txn->unprep_seqs_[snapshot2->GetSequenceNumber() + 1] =
      snapshot4->GetSequenceNumber() - snapshot2->GetSequenceNumber();

  iter->SeekForPrev("b");
  verify_state(iter, "b", "v4");

  iter->Prev();
  verify_state(iter, "a", "v3");

  iter->SeekToLast();
  verify_state(iter, "b", "v4");

  iter->Prev();
  verify_state(iter, "a", "v3");

  delete iter;
  roptions.snapshot = snapshot6;
  iter = txn->GetIterator(roptions);
  wup_txn->unprep_seqs_[snapshot6->GetSequenceNumber() + 1] =
      snapshot8->GetSequenceNumber() - snapshot6->GetSequenceNumber();

  iter->SeekForPrev("b");
  verify_state(iter, "b", "v8");

  iter->Prev();
  verify_state(iter, "a", "v7");

  iter->SeekToLast();
  verify_state(iter, "b", "v8");

  iter->Prev();
  verify_state(iter, "a", "v7");

  db->ReleaseSnapshot(snapshot0);
  db->ReleaseSnapshot(snapshot2);
  db->ReleaseSnapshot(snapshot4);
  db->ReleaseSnapshot(snapshot6);
  db->ReleaseSnapshot(snapshot8);
  delete iter;
  delete txn;
}

}  // namespace rocksdb

int main(int argc, char** argv) {
  ::testing::InitGoogleTest(&argc, argv);
  return RUN_ALL_TESTS();
}

#else
#include <stdio.h>

int main(int /*argc*/, char** /*argv*/) {
  fprintf(stderr,
          "SKIPPED as Transactions are not supported in ROCKSDB_LITE\n");
  return 0;
}

#endif  // ROCKSDB_LITE
