# coinone-prda-query
코인원 Homework Test에 활용한 쿼리 공유 드립니다.
해당 과제에 2가지 쿼리를 활용하여 데이터를 분석했습니다. 

1. 2월 dt 기준 top10% 거래 비중
- 2025년 2월 기준 dt별로 거래 금액 기준 상위 10%, 20% 금액 추출
- 상위 10%, 상위 20%가 거래 비중 및 코인원 거래 활성화에 얼만큼의 Impact가 있는가 분석하기 위한 목적으로 활용

2. User_segment
- 유저별 세그먼트 분류를 위한 목적으로 활용
- Output Data는 2월 거래 완료한 유저(Trade_log)를 기준으로 각 유저별로 Group_segment와 Retention_segment 추출

Standard	Metric	Description	
1. 가입 기준
- new	: 2024년 가입한 신규 유저 	
- base : 2024년 이전에 가입한 유저

2. Metric 정의 기준
- MAU	: 2024년 2월에 trade_log table 기준 거래 금액 기준 1건 이상 거래한 유저	
- WAU	: 2024년 2월 해당 Week에 trade_log table 기준 거래 금액 기준 1건 이상 거래한 유저	
- w_Retention	: week 기준으로 거래 금액 기준 1건 이상 거래한 유저


3. Group Segment
- loyalty	Group : 2024년 이전에 가입한 유저이면서, 2월 MAU 유저 중에서 거래 금액 기준 상위 20% 유저 	
- potential Group : 2024년에 가입한 유저이면서, 2월 MAU 유저 중에서 거래 금액 기준 상위 20% 유저	
- new Group : 2024년에 가입한 유저 중 potential group user을 제외한 유저
- base Group : 거래 완료 기준 2월 MAU한 유저 - (loyalty,potential,new group user)

4. Retention Segment	
- 1w_retention : 최근 Week에 리탠션한 유저	
  * 최근 : 2월 마지막 Week(테이블에서 가장 최근 dt)
- 2w_retention : 최근 2week 연속 리탠션한 유저	
- 3w_retention : 최근 3week 연속 리탠션한 유저	
- 4w_retention : 최근 4week 연속 리탠션한 유저	
- 1w_churn : 최근 Week에 이탈한 유저	
