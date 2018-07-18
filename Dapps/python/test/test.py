# coding=utf-8


from test import recommendations


# 유클리디안 계산 결과 계산하기
print(recommendations.sim_distance(recommendations.critics, 'Lisa Rose', 'Gene Seymour'))

# 피어슨 결과...
print(recommendations.sim_pearson(recommendations.critics, 'Lisa Rose', 'Gene Seymour'))

# 평론가 순위 매기기
print(recommendations.top_matches(recommendations.critics, 'Toby'))