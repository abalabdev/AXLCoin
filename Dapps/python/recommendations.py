#!/usr/bin/env python
# -*- coding: utf-8 -*-
from math import sqrt
#영화 비평과 영화 평가 정보를 담는 딕셔너리
critics = {
    'Lisa Rose': {
        'Lady in the Water': 2.5,
        'Snakes on a Plane': 3.5,
        'Just My Luck': 3.0,
        'Superman Returns': 3.5,
        'You, Me and Dupree': 2.5,
        'The Night Listener': 3.0,
    },
    'Gene Seymour': {
        'Lady in the Water': 3.0,
        'Snakes on a Plane': 3.5,
        'Just My Luck': 1.5,
        'Superman Returns': 5.0,
        'The Night Listener': 3.0,
        'You, Me and Dupree': 3.5,
    },
    'Michael Phillips': {
        'Lady in the Water': 2.5,
        'Snakes on a Plane': 3.0,
        'Superman Returns': 3.5,
        'The Night Listener': 4.0,
    },
    'Claudia Puig': {
        'Snakes on a Plane': 3.5,
        'Just My Luck': 3.0,
        'The Night Listener': 4.5,
        'Superman Returns': 4.0,
        'You, Me and Dupree': 2.5,
    },
    'Mick LaSalle': {
        'Lady in the Water': 3.0,
        'Snakes on a Plane': 4.0,
        'Just My Luck': 2.0,
        'Superman Returns': 3.0,
        'The Night Listener': 3.0,
        'You, Me and Dupree': 2.0,
    },
    'Jack Matthews': {
        'Lady in the Water': 3.0,
        'Snakes on a Plane': 4.0,
        'The Night Listener': 3.0,
        'Superman Returns': 5.0,
        'You, Me and Dupree': 3.5,
    },
    'Toby': {'Snakes on a Plane': 4.5, 'You, Me and Dupree': 1.0,
             'Superman Returns': 4.0},
}


def sim_distance(prefs, p1, p2):
    
   # person1과 person2의 거리 기반 유사도 점수리턴
    

    #공통 항목 목록 추출
    si = {}
    for item in prefs[p1]:
        if item in prefs[p2]:
            si[item] = 1
    #공통 평가 항목이없는 경우 0 리턴
    if len(si) == 0:
        return 0
    #모든 값의 제곱을 더함
    sum_of_squares = sum([pow(prefs[p1][item] - prefs[p2][item], 2) for item in
                         prefs[p1] if item in prefs[p2]])
    return 1 / (1 + sqrt(sum_of_squares))


def sim_pearson(prefs, p1, p2):
    
    #p1과p2에 대한 피어슨 상관계수를 리턴
    

    #같이 평가한 항목들의 목록을 구함
    si = {}
    for item in prefs[p1]:
        if item in prefs[p2]:
            si[item] = 1
    #공통 요소가 없으면 0을리턴
    if len(si) == 0:
        return 0
    #요소들의 개수를 구함
    n = len(si)
    #모든 선호도를 합산
    sum1 = sum([prefs[p1][it] for it in si])
    sum2 = sum([prefs[p2][it] for it in si])
    #제곱의 합을계산
    sum1Sq = sum([pow(prefs[p1][it], 2) for it in si])
    sum2Sq = sum([pow(prefs[p2][it], 2) for it in si])
    #곱의 합을계산
    pSum = sum([prefs[p1][it] * prefs[p2][it] for it in si])
    #피어슨 점수 계산
    num = pSum - sum1 * sum2 / n
    den = sqrt((sum1Sq - pow(sum1, 2) / n) * (sum2Sq - pow(sum2, 2) / n))
    if den == 0:
        return 0
    r = num / den
    return r

def top_matches(prefs, person, n=5, similarity=sim_pearson):
    scores = [(similarity(prefs, person, other), other) for other in prefs if other != person]

    scores.sort()
    scores.reverse()

    return scores[0:n]


def get_recommataions(prefs, person, similarity=sim_pearson):
    totals = {}
    sim_sums = {}

    for other in prefs:
        # 나와 나는 비교하지않는다.
        if other == person:
            continue

        sim = similarity(prefs, person, other)

        # 0이하의 점수는 무시함
        if sim <= 0:
            continue
        for item in prefs[other]:
            # 내가 보지 못한 영화만 대상으로 한다.
            if item not in prefs[person] or prefs[person][item] == 0:
                # 유사도 * 점수
                totals.setdefault(item, 0)
                totals[item] += prefs[other][item] * sim

                # 유사도 합계
                sim_sums.setdefault(item, 0)
                sim_sums[item] += sim

    # 정규화된 목록 생성
    rankings = [(total / sim_sums[item], item) for item, total in totals.items()]

    # 정렬된 목록 리턴
    rankings.sort()
    rankings.reverse()

    return rankings


def transform_prefs(prefs):
    result = {}
    for person in prefs:
        for item in prefs[person]:
            result.setdefault(item, {})
            result[item][person] = prefs[person][item]

    return result


def calculate_similar_items(prefs, n=10):
    # 가장 유사한항목들을가진 항목 딕셔너리를 생성
    result = {}

    # 선호도 행렬을 뒤집어 항목 중심 행렬로 변경
    item_prefs = transform_prefs(prefs)

    c = 0
    for item in item_prefs:
        # 큰 데이터 세트를 위해 진척 상태를 갱신
        c += 1
        if c % 100 == 0:
            print("%d/%d", c, len(item_prefs))

        # 각항목과 가장 유사한 항목들을 구함
        scores = top_matches(item_prefs, item, n, sim_distance)
        result[item] = scores

    return result


def get_recommended_items(prefs, itemMatch, user):
    user_ratings = prefs[user]
    scores = {}
    total_sim = {}
    # 이 사용자가 평가한 모든 항목마다 루프를 돈다.
    for (item, rating) in user_ratings.items():

        # 이항목과 유사한 모든 항목마다 루프를 돈다.
        for (similarity, item2) in itemMatch[item]:

            # 이미사용자가 항목을 평가했다면 무시한다.
            if item2 in user_ratings:
                continue
            # 유사도와 평가점수 곱의가중치 합을 계산
            scores.setdefault(item2, 0)
            scores[item2] += similarity * rating
            # 모든 유사도 합을 계산
            total_sim.setdefault(item2, 0)
            total_sim[item2] += similarity

    # 평균값을 얻기 위해 합계를 가중치 합계로 나눔
    rankings = [(score / total_sim[item], item) for item, score in scores.items()]

    # 최고값에서 최저값으로 랭킹을 리턴함.
    rankings.sort()
    rankings.reverse()
    return rankings

# 영화제목을 얻음
def load_movie_lens(path='movielens/'):
    movies = {}
    for line in open(path + "item.data"):
        (m_id, m_title) = line.split('|')[0:2]
        movies[m_id] = m_title
#데이터를 로드
    prefs = {}
    for line in open(path + "rating.data"):
        (user, m_id, rating, ts) = line.split('\t')
        prefs.setdefault(user, {})
        prefs[user][movies[m_id]] = float(rating)

    return prefs


# 유저 유사도 측정.
def calculate_similar_user(prefs, n=10):
    # 가장 유사한항목들을가진 항목 딕셔너리를 생성
    result = {}
    c = 0
    for user in prefs:
        # 큰 데이터 세트를 위해 진척 상태를 갱신
        c += 1
        if c % 100 == 0:
            print("%d/%d", c, len(prefs))

        # 각항목과 가장 유사한 항목들을 구함
        scores = top_matches(prefs, user, n, sim_distance)
        result[user] = scores

    return result


