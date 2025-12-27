-- JobFlow 데이터베이스 초기화 스크립트

-- 확장 기능 활성화
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";  -- 텍스트 검색 최적화

-- 타임존 설정
SET timezone = 'Asia/Seoul';

-- 기본 스키마 확인
SELECT current_database(), current_schema();

-- 데이터베이스 설정 확인
SHOW server_encoding;
SHOW lc_collate;
SHOW lc_ctype;

-- 완료 메시지
DO $$
BEGIN
    RAISE NOTICE '================================================';
    RAISE NOTICE 'JobFlow 데이터베이스 초기화 완료';
    RAISE NOTICE 'Database: %', current_database();
    RAISE NOTICE 'User: %', current_user;
    RAISE NOTICE '================================================';
END $$;