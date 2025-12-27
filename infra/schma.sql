-- ================================================
-- JobFlow 데이터베이스 스키마
-- PostgreSQL 15+
-- ================================================

-- 기존 테이블 삭제 (개발 환경용)
DROP TABLE IF EXISTS job_tech_stacks CASCADE;
DROP TABLE IF EXISTS job_postings CASCADE;
DROP TABLE IF EXISTS tech_stacks CASCADE;
DROP TABLE IF EXISTS companies CASCADE;
DROP TABLE IF EXISTS job_categories CASCADE;

-- ================================================
-- 1. Companies (회사)
-- ================================================
CREATE TABLE companies (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    website_url VARCHAR(500),
    logo_url VARCHAR(200),
    si VARCHAR(100),
    gu VARCHAR(100),
    detail_address VARCHAR(100),
    employee_count INTEGER,
    industry VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 인덱스 생성
CREATE INDEX idx_companies_name ON companies(name);
CREATE INDEX idx_companies_si_gu ON companies(si, gu);

-- 코멘트 추가
COMMENT ON TABLE companies IS '회사 정보';
COMMENT ON COLUMN companies.name IS '회사명 (고유)';
COMMENT ON COLUMN companies.si IS '시 (예: 서울특별시)';
COMMENT ON COLUMN companies.gu IS '구 (예: 강남구)';
COMMENT ON COLUMN companies.detail_address IS '상세 주소 (도로명)';
COMMENT ON COLUMN companies.employee_count IS '직원 수';
COMMENT ON COLUMN companies.industry IS '업종';

-- ================================================
-- 2. Job Categories (직무 카테고리)
-- ================================================
CREATE TABLE job_categories (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 코멘트 추가
COMMENT ON TABLE job_categories IS '직무 카테고리 (백엔드, 프론트엔드 등)';
COMMENT ON COLUMN job_categories.name IS '카테고리명';

-- ================================================
-- 3. Job Postings (채용 공고)
-- ================================================
CREATE TABLE job_postings (
    id BIGSERIAL PRIMARY KEY,
    source VARCHAR(50) NOT NULL,
    job_id VARCHAR(100) NOT NULL,
    company_id BIGINT NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
    category_id BIGINT REFERENCES job_categories(id) ON DELETE SET NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    si VARCHAR(100),
    gu VARCHAR(100),
    detail_address VARCHAR(100),
    experience_level VARCHAR(50),
    employment_type VARCHAR(50),
    salary_min INTEGER,
    salary_max INTEGER,
    salary_negotiable BOOLEAN DEFAULT FALSE,
    education VARCHAR(50),
    url VARCHAR(500) NOT NULL,
    posted_at DATE NOT NULL,
    deadline DATE,
    is_active BOOLEAN DEFAULT TRUE,
    crawled_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    -- 제약 조건
    CONSTRAINT uk_job_postings_source_job_id UNIQUE (source, job_id),
    CONSTRAINT chk_salary_range CHECK (salary_min IS NULL OR salary_max IS NULL OR salary_min <= salary_max),
    CONSTRAINT chk_date_range CHECK (deadline IS NULL OR posted_at <= deadline)
);

-- 인덱스 생성
CREATE INDEX idx_job_postings_company_id ON job_postings(company_id);
CREATE INDEX idx_job_postings_category_id ON job_postings(category_id);
CREATE INDEX idx_job_postings_posted_at_desc ON job_postings(posted_at DESC);
CREATE INDEX idx_job_postings_is_active ON job_postings(is_active);
CREATE INDEX idx_job_postings_posted_active ON job_postings(posted_at DESC, is_active) WHERE is_active = TRUE;
CREATE INDEX idx_job_postings_si_gu ON job_postings(si, gu);
CREATE INDEX idx_job_postings_experience ON job_postings(experience_level);
CREATE INDEX idx_job_postings_employment ON job_postings(employment_type);

-- Full-text search 인덱스 (한국어 검색용)
CREATE INDEX idx_job_postings_title_fulltext ON job_postings USING gin(to_tsvector('simple', title));
CREATE INDEX idx_job_postings_description_fulltext ON job_postings USING gin(to_tsvector('simple', description));

-- 코멘트 추가
COMMENT ON TABLE job_postings IS '채용 공고';
COMMENT ON COLUMN job_postings.source IS '출처 (saramin, rocketpunch)';
COMMENT ON COLUMN job_postings.job_id IS '사이트별 공고 고유 ID';
COMMENT ON COLUMN job_postings.si IS '근무지 시';
COMMENT ON COLUMN job_postings.gu IS '근무지 구';
COMMENT ON COLUMN job_postings.experience_level IS '경력 (신입, 경력, 무관)';
COMMENT ON COLUMN job_postings.employment_type IS '고용형태 (인턴, 정규직, 계약직)';
COMMENT ON COLUMN job_postings.salary_min IS '최소 연봉 (만원 단위)';
COMMENT ON COLUMN job_postings.salary_max IS '최대 연봉 (만원 단위)';
COMMENT ON COLUMN job_postings.is_active IS '활성 여부 (소프트 삭제용)';

-- ================================================
-- 4. Tech Stacks (기술 스택)
-- ================================================
CREATE TABLE tech_stacks (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    category VARCHAR(50) NOT NULL,
    normalized_name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 인덱스 생성
CREATE INDEX idx_tech_stacks_category ON tech_stacks(category);
CREATE INDEX idx_tech_stacks_normalized_name ON tech_stacks(normalized_name);

-- 코멘트 추가
COMMENT ON TABLE tech_stacks IS '기술 스택 (Python, Django 등)';
COMMENT ON COLUMN tech_stacks.name IS '기술명 (표시용)';
COMMENT ON COLUMN tech_stacks.category IS '분류 (언어, 프레임워크, DB, 도구)';
COMMENT ON COLUMN tech_stacks.normalized_name IS '정규화된 이름 (검색용, 소문자)';

-- ================================================
-- 5. Job Tech Stacks (채용공고-기술스택 연결)
-- ================================================
CREATE TABLE job_tech_stacks (
    id BIGSERIAL PRIMARY KEY,
    job_posting_id BIGINT NOT NULL REFERENCES job_postings(id) ON DELETE CASCADE,
    tech_stack_id BIGINT NOT NULL REFERENCES tech_stacks(id) ON DELETE CASCADE,
    is_required BOOLEAN DEFAULT TRUE,

    -- 제약 조건
    CONSTRAINT uk_job_tech_stacks_job_tech UNIQUE (job_posting_id, tech_stack_id)
);

-- 인덱스 생성
CREATE INDEX idx_job_tech_stacks_job_posting ON job_tech_stacks(job_posting_id);
CREATE INDEX idx_job_tech_stacks_tech_stack ON job_tech_stacks(tech_stack_id);
CREATE INDEX idx_job_tech_stacks_required ON job_tech_stacks(is_required);

-- 코멘트 추가
COMMENT ON TABLE job_tech_stacks IS '채용 공고와 기술 스택의 N:M 관계';
COMMENT ON COLUMN job_tech_stacks.is_required IS '필수 기술 여부';

-- ================================================
-- 트리거: updated_at 자동 업데이트
-- ================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Companies 테이블 트리거
CREATE TRIGGER trg_companies_updated_at
    BEFORE UPDATE ON companies
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Job Postings 테이블 트리거
CREATE TRIGGER trg_job_postings_updated_at
    BEFORE UPDATE ON job_postings
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ================================================
-- 초기 데이터 삽입
-- ================================================

-- Job Categories 초기 데이터
INSERT INTO job_categories (name, description) VALUES
    ('백엔드', '서버 개발'),
    ('프론트엔드', '클라이언트 개발'),
    ('풀스택', '백엔드/프론트엔드 모두'),
    ('데이터엔지니어', '데이터 파이프라인'),
    ('데이터분석', '데이터 분석 및 시각화'),
    ('AI/ML', '인공지능 및 머신러닝'),
    ('DevOps', '인프라 및 배포'),
    ('모바일', '모바일 앱 개발'),
    ('게임', '게임 개발'),
    ('보안', '정보 보안'),
    ('QA', '품질 관리'),
    ('기타', '기타 직무')
ON CONFLICT (name) DO NOTHING;

-- Tech Stacks 초기 데이터
INSERT INTO tech_stacks (name, category, normalized_name) VALUES
    -- 프로그래밍 언어
    ('Python', '언어', 'python'),
    ('Java', '언어', 'java'),
    ('JavaScript', '언어', 'javascript'),
    ('TypeScript', '언어', 'typescript'),
    ('Go', '언어', 'go'),
    ('Kotlin', '언어', 'kotlin'),
    ('Swift', '언어', 'swift'),
    ('C++', '언어', 'cpp'),
    ('C#', '언어', 'csharp'),
    ('Ruby', '언어', 'ruby'),
    ('PHP', '언어', 'php'),
    ('Rust', '언어', 'rust'),

    -- 백엔드 프레임워크
    ('Django', '프레임워크', 'django'),
    ('FastAPI', '프레임워크', 'fastapi'),
    ('Flask', '프레임워크', 'flask'),
    ('Spring Boot', '프레임워크', 'springboot'),
    ('Spring', '프레임워크', 'spring'),
    ('Node.js', '프레임워크', 'nodejs'),
    ('Express.js', '프레임워크', 'expressjs'),
    ('NestJS', '프레임워크', 'nestjs'),
    ('Ruby on Rails', '프레임워크', 'rails'),
    ('Laravel', '프레임워크', 'laravel'),
    ('ASP.NET', '프레임워크', 'aspnet'),

    -- 프론트엔드 프레임워크
    ('React', '프레임워크', 'react'),
    ('Vue.js', '프레임워크', 'vuejs'),
    ('Angular', '프레임워크', 'angular'),
    ('Next.js', '프레임워크', 'nextjs'),
    ('Nuxt.js', '프레임워크', 'nuxtjs'),
    ('Svelte', '프레임워크', 'svelte'),

    -- 데이터베이스
    ('PostgreSQL', '데이터베이스', 'postgresql'),
    ('MySQL', '데이터베이스', 'mysql'),
    ('MongoDB', '데이터베이스', 'mongodb'),
    ('Redis', '데이터베이스', 'redis'),
    ('Oracle', '데이터베이스', 'oracle'),
    ('MS SQL Server', '데이터베이스', 'mssql'),
    ('SQLite', '데이터베이스', 'sqlite'),
    ('Elasticsearch', '데이터베이스', 'elasticsearch'),
    ('Cassandra', '데이터베이스', 'cassandra'),

    -- 클라우드/인프라
    ('AWS', '클라우드', 'aws'),
    ('GCP', '클라우드', 'gcp'),
    ('Azure', '클라우드', 'azure'),
    ('Docker', '도구', 'docker'),
    ('Kubernetes', '도구', 'kubernetes'),
    ('Jenkins', '도구', 'jenkins'),
    ('GitHub Actions', '도구', 'githubactions'),
    ('Terraform', '도구', 'terraform'),

    -- 데이터/AI
    ('Apache Spark', '도구', 'spark'),
    ('Apache Kafka', '도구', 'kafka'),
    ('Apache Airflow', '도구', 'airflow'),
    ('TensorFlow', '도구', 'tensorflow'),
    ('PyTorch', '도구', 'pytorch'),
    ('Pandas', '도구', 'pandas'),
    ('scikit-learn', '도구', 'scikitlearn'),

    -- 버전 관리/협업
    ('Git', '도구', 'git'),
    ('GitHub', '도구', 'github'),
    ('GitLab', '도구', 'gitlab'),
    ('Jira', '도구', 'jira'),
    ('Confluence', '도구', 'confluence')
ON CONFLICT (name) DO NOTHING;

-- ================================================
-- 뷰: 활성 공고 통계
-- ================================================
CREATE OR REPLACE VIEW v_active_jobs_stats AS
SELECT
    c.name AS category_name,
    COUNT(*) AS job_count,
    AVG(salary_min) AS avg_salary_min,
    AVG(salary_max) AS avg_salary_max
FROM job_postings jp
JOIN job_categories c ON jp.category_id = c.id
WHERE jp.is_active = TRUE
GROUP BY c.id, c.name
ORDER BY job_count DESC;

COMMENT ON VIEW v_active_jobs_stats IS '직무 카테고리별 활성 공고 통계';

-- ================================================
-- 뷰: 기술스택별 공고 수
-- ================================================
CREATE OR REPLACE VIEW v_tech_stack_stats AS
SELECT
    ts.name AS tech_name,
    ts.category AS tech_category,
    COUNT(DISTINCT jts.job_posting_id) AS job_count,
    SUM(CASE WHEN jts.is_required THEN 1 ELSE 0 END) AS required_count,
    SUM(CASE WHEN NOT jts.is_required THEN 1 ELSE 0 END) AS preferred_count
FROM tech_stacks ts
LEFT JOIN job_tech_stacks jts ON ts.id = jts.tech_stack_id
LEFT JOIN job_postings jp ON jts.job_posting_id = jp.id AND jp.is_active = TRUE
GROUP BY ts.id, ts.name, ts.category
ORDER BY job_count DESC;

COMMENT ON VIEW v_tech_stack_stats IS '기술 스택별 활성 공고 수 통계';

-- ================================================
-- 완료 메시지
-- ================================================
DO $$
BEGIN
    RAISE NOTICE '================================================';
    RAISE NOTICE 'JobFlow 데이터베이스 스키마 생성 완료!';
    RAISE NOTICE '================================================';
    RAISE NOTICE '생성된 테이블:';
    RAISE NOTICE '  - companies (회사)';
    RAISE NOTICE '  - job_categories (직무 카테고리)';
    RAISE NOTICE '  - job_postings (채용 공고)';
    RAISE NOTICE '  - tech_stacks (기술 스택)';
    RAISE NOTICE '  - job_tech_stacks (공고-기술 연결)';
    RAISE NOTICE '';
    RAISE NOTICE '생성된 뷰:';
    RAISE NOTICE '  - v_active_jobs_stats (카테고리별 통계)';
    RAISE NOTICE '  - v_tech_stack_stats (기술스택별 통계)';
    RAISE NOTICE '================================================';
END $$;