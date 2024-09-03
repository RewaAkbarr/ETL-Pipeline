SELECT 'CREATE DATABASE postgres_db'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'postgres_db')\gexec