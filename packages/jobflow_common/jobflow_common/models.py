from datetime import datetime, date
from typing import Optional
from pydantic import BaseModel, Field


# ================================================
# 1. Company (회사)
# ================================================
class Company(BaseModel):
    """회사 정보 모델"""

    id: Optional[int] = None
    name: str = Field(..., max_length=100, description="회사명")
    description: Optional[str] = Field(None, description="회사 설명")
    website_url: Optional[str] = Field(None, max_length=500, description="웹사이트 URL")
    logo_url: Optional[str] = Field(None, max_length=200, description="로고 이미지 URL")
    si: Optional[str] = Field(None, max_length=100, description="시 (예: 서울특별시)")
    gu: Optional[str] = Field(None, max_length=100, description="구 (예: 강남구)")
    detail_address: Optional[str] = Field(None, max_length=100, description="상세 주소 (도로명)")
    employee_count: Optional[int] = Field(None, description="직원 수")
    industry: Optional[str] = Field(None, max_length=50, description="업종")
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


# ================================================
# 2. JobCategory (직무 카테고리)
# ================================================
class JobCategory(BaseModel):
    """직무 카테고리 모델"""

    id: Optional[int] = None
    name: str = Field(..., max_length=50, description="카테고리명 (예: 백엔드, 프론트엔드)")
    description: Optional[str] = Field(None, max_length=100, description="카테고리 설명")
    created_at: Optional[datetime] = None

    class Config:
        from_attributes = True


# ================================================
# 3. TechStack (기술 스택)
# ================================================
class TechStack(BaseModel):
    """기술 스택 모델"""

    id: Optional[int] = None
    name: str = Field(..., max_length=50, description="기술명 (예: Python, Django)")
    category: str = Field(..., max_length=50, description="분류 (언어, 프레임워크, DB, 도구)")
    normalized_name: str = Field(..., max_length=100, description="정규화된 이름 (소문자, 검색용)")
    created_at: Optional[datetime] = None

    class Config:
        from_attributes = True


# ================================================
# 4. JobPosting (채용 공고)
# ================================================
class JobPosting(BaseModel):
    """채용 공고 모델"""

    id: Optional[int] = None
    source: str = Field(..., max_length=50, description="출처 (saramin, rocketpunch)")
    job_id: str = Field(..., max_length=100, description="사이트별 공고 고유 ID")
    company_id: int = Field(..., description="회사 ID (FK)")
    category_id: Optional[int] = Field(None, description="직무 카테고리 ID (FK)")
    title: str = Field(..., max_length=200, description="공고 제목")
    description: str = Field(..., description="상세 설명")
    si: Optional[str] = Field(None, max_length=100, description="근무지 시")
    gu: Optional[str] = Field(None, max_length=100, description="근무지 구")
    detail_address: Optional[str] = Field(None, max_length=100, description="근무지 상세 주소")
    experience_level: Optional[str] = Field(None, max_length=50, description="경력 (신입, 경력, 무관)")
    employment_type: Optional[str] = Field(None, max_length=50, description="고용형태 (인턴, 정규직, 계약직)")
    salary_min: Optional[int] = Field(None, description="최소 연봉 (만원)")
    salary_max: Optional[int] = Field(None, description="최대 연봉 (만원)")
    salary_negotiable: bool = Field(False, description="연봉협의 여부")
    education: Optional[str] = Field(None, max_length=50, description="학력 (무관, 학사, 석사)")
    url: str = Field(..., max_length=500, description="원문 URL")
    posted_at: date = Field(..., description="게시일")
    deadline: Optional[date] = Field(None, description="마감일")
    is_active: bool = Field(True, description="활성 여부")
    crawled_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


# ================================================
# 5. JobTechStack (채용공고-기술스택 연결)
# ================================================
class JobTechStack(BaseModel):
    """채용 공고와 기술 스택의 N:M 관계 모델"""

    id: Optional[int] = None
    job_posting_id: int = Field(..., description="채용 공고 ID (FK)")
    tech_stack_id: int = Field(..., description="기술 스택 ID (FK)")
    is_required: bool = Field(True, description="필수 기술 여부 (True: 필수, False: 우대)")

    class Config:
        from_attributes = True


# ================================================
# 확장 모델 (관계 포함)
# ================================================
class JobPostingWithRelations(JobPosting):
    """관계가 포함된 채용 공고 모델 (API 응답용)"""

    company: Optional[Company] = None
    category: Optional[JobCategory] = None
    tech_stacks: list[TechStack] = []


class CompanyWithJobs(Company):
    """공고 목록이 포함된 회사 모델"""

    job_postings: list[JobPosting] = []


class TechStackWithJobCount(TechStack):
    """공고 수가 포함된 기술 스택 모델 (통계용)"""

    job_count: int = 0
    required_count: int = 0
    preferred_count: int = 0