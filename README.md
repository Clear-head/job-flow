# JobFlow

> 채용 공고 수집 및 기술 트렌드 분석 플랫폼

## 📋 프로젝트 개요

JobFlow는 주요 한국 채용 사이트의 채용 공고를 수집하고, NLP 분석을 통해 기술 스택 트렌드를 제공하는 데이터 파이프라인 플랫폼입니다.

### 주요 기능

- 🕷️ **자동 채용 공고 수집**: Scrapy를 활용한 윤리적 웹 크롤링
- 🔄 **파이프라인 오케스트레이션**: Airflow를 통한 ETL 자동화
- 📊 **기술 트렌드 분석**: NLP 기반 기술 스택 추출 및 통계
- 🔍 **REST API 제공**: Django 기반 검색/필터링 API
- 📈 **데이터 품질 관리**: Great Expectations를 통한 검증

## 🛠️ 기술 스택

### 데이터 수집
- **Scrapy 2.12+**: 웹 크롤링 프레임워크
- **Playwright**: 동적 페이지 렌더링

### 데이터 파이프라인
- **Apache Airflow 3.1**: 워크플로우 오케스트레이션
- **Great Expectations**: 데이터 품질 검증

### 백엔드 API
- **Django 5.2**: 웹 프레임워크
- **Django REST Framework**: REST API
- **Celery**: 비동기 작업 처리

### 데이터 저장소
- **PostgreSQL 15+**: 메인 데이터베이스
- **ElasticSearch 8**: 전문 검색 엔진
- **Redis 5+**: 캐싱 및 메시지 브로커

### 개발 도구
- **Python 3.12**: 프로그래밍 언어
- **Poetry**: 패키지 관리
- **Docker & Docker Compose**: 컨테이너화
- **pytest**: 테스트 프레임워크


## 🚀 시작하기

```bash
# Django API 서버
cd service/api
python manage.py runserver

# Scrapy 크롤러 (테스트)
cd service/crawler
scrapy crawl rocketpunch

# Airflow (Docker 사용 권장)
cd infrastructure
docker-compose up airflow-webserver airflow-scheduler
```

#### 프로덕션 모드

```bash
cd infrastructure
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

## 📊 데이터 파이프라인

### 일일 수집 DAG (daily_collection)
```
수집 → 검증 → 정규화 → 적재 → 인덱싱
```

### 주간 분석 DAG (weekly_analysis)
```
데이터 추출 → 기술 스택 추출 (NLP) → 트렌드 계산 → 리포트 생성
```

## 🔍 API 엔드포인트

### 채용 공고
```http
GET    /api/jobs/              # 공고 목록 (필터링/검색)
GET    /api/jobs/{id}/         # 공고 상세
GET    /api/jobs/search/       # ElasticSearch 검색
```

### 통계
```http
GET    /api/analytics/tech-trends/     # 기술 트렌드
GET    /api/analytics/company-stats/   # 회사별 통계
GET    /api/analytics/salary-stats/    # 급여 통계
```

### 회사 정보
```http
GET    /api/companies/         # 회사 목록
GET    /api/companies/{id}/    # 회사 상세
```

API 문서: http://localhost:8000/api/docs/ (Swagger UI)

## 🗃️ 데이터베이스 스키마

주요 테이블:
- `job_postings`: 채용 공고
- `companies`: 회사 정보
- `tech_stacks`: 기술 스택
- `job_tech_stacks`: 공고-기술 매핑
- `analytics_trends`: 트렌드 통계
