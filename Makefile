include .env

help:
	@echo "## docker-build			- Build Docker Images (amd64) including its inter-container network."
	@echo "## docker-build-arm		- Build Docker Images (arm64) including its inter-container network."
	@echo "## postgres			- Run a Postgres container  "
	@echo "## spark			- Run a Spark cluster, rebuild the postgres container, then create the destination tables "
	@echo "## jupyter			- Spinup jupyter notebook for testing and validation purposes."
	@echo "## airflow			- Spinup airflow scheduler and webserver."
	@echo "## kafka			- Spinup kafka cluster (Kafka+Zookeeper)."
	@echo "## datahub			- Spinup datahub instances."
	@echo "## metabase			- Spinup metabase instance."
	@echo "## clean			- Cleanup all running containers related to the challenge."

docker-build-slim:
	@chmod 777 logs/
	@chmod 777 notebooks/
	@docker network inspect dataeng-network >/dev/null 2>&1 || docker network create dataeng-network
	@docker build -t dataeng-dibimbing/jupyter -f ./docker/Dockerfile.jupyter .

docker-build:
	@echo '__________________________________________________________'
	@echo 'Building Docker Images ...'
	@echo '__________________________________________________________'
	@chmod 777 logs/
	@chmod 777 notebooks/
	@docker network inspect dataeng-network >/dev/null 2>&1 || docker network create dataeng-network
	@echo '__________________________________________________________'
	@docker build -t dataeng-dibimbing/spark -f ./docker/Dockerfile.spark .
	@echo '__________________________________________________________'
	@docker build -t dataeng-dibimbing/airflow -f ./docker/Dockerfile.airflow .
	@echo '__________________________________________________________'
	@docker build -t dataeng-dibimbing/jupyter -f ./docker/Dockerfile.jupyter .
	@echo '==========================================================='

docker-build-arm:
	@echo '__________________________________________________________'
	@echo 'Building Docker Images ...'
	@echo '__________________________________________________________'
	@docker network inspect rewastack-network >/dev/null 2>&1 || docker network create rewastack-network
	@echo '__________________________________________________________'
	@docker build -t mrewaakbari06/rewastack:latest -f ./docker/Dockerfile.airflow-arm .
	@echo '__________________________________________________________'
	@docker build -t mrewaakbari06/rewastack:latest -f ./docker/Dockerfile.spark .
	@echo '__________________________________________________________'
	@docker build -t mrewaakbari06/rewastack:latest -f./docker/Dockerfile.jupyter .
	@echo '__________________________________________________________'

jupyter:
	@echo '__________________________________________________________'
	@echo 'Creating Jupyter Notebook Cluster at http://localhost:${JUPYTER_PORT} ...'
	@echo '__________________________________________________________'
	@docker compose -f ./docker/docker-compose-jupyter.yml --env-file .env up -d
	@echo 'Created...'
	@echo 'Processing token...'
	@sleep 20
	@docker logs ${JUPYTER_CONTAINER_NAME} 2>&1 | grep '\?token\=' -m 1 | cut -d '=' -f2
	@echo '==========================================================='

spark:
	@echo '__________________________________________________________'
	@echo 'Creating Spark Cluster ...'
	@echo '__________________________________________________________'
	@docker compose -f ./docker/docker-compose-spark.yml --env-file .env up -d
	@docker build -t mrewaakbari06/rewastack:latest -f ./docker/Dockerfile.spark .

spark-submit-test:
	@docker exec ${SPARK_WORKER_CONTAINER_NAME}-1 \
		spark-submit \
		--master spark://${SPARK_MASTER_HOST_NAME}:${SPARK_MASTER_PORT} \
		/spark-scripts/ingest.py 


spark-submit-airflow-test:
	@docker exec ${AIRFLOW_WEBSERVER_CONTAINER_NAME} \
		spark-submit \
		--master spark://${SPARK_MASTER_HOST_NAME}:${SPARK_MASTER_PORT} \
		--conf "spark.standalone.submit.waitAppCompletion=false" \
		--conf "spark.ui.enabled=false" \
		/spark-scripts/transform.py 
airflow:
	@echo '__________________________________________________________'
	@echo 'Creating Airflow Instance ...'
	@echo '__________________________________________________________'
	@docker compose -f ./docker/docker-compose-airflow.yml --env-file .env up
	@echo '==========================================================='

sqlserver-create:
	@echo '__________________________________________________________'
	@docker compose -f ./docker/docker-compose-sql.yml --env-file .env up -d
	@docker build -t dataeng-dibimbing/sql:latest -f ./docker/Dockerfile.sql .
	
mage-ai:
	@echo '__________________________________________________________'
	@echo 'Creating Mage AI Instance ...'
	@echo '__________________________________________________________'
	@docker compose -f ./docker/docker-compose.yml --env-file .env up
	@echo '==========================================================='

postgres: postgres-create postgres-create-warehouse postgres-create-table postgres-ingest-csv

postgres-create:
	@docker compose -f ./docker/docker-compose-postgres.yml --env-file .env up -d
	@echo '__________________________________________________________'
	@echo 'Postgres container created at port ${POSTGRES_PORT}...'
	@echo '__________________________________________________________'
	@echo 'Postgres Docker Host	: ${POSTGRES_CONTAINER_NAME}' &&\
		echo 'Postgres Account	: ${POSTGRES_USER}' &&\
		echo 'Postgres password	: ${POSTGRES_PASSWORD}' &&\
		echo 'Postgres Db		: ${POSTGRES_DB}'
	@sleep 5
	@echo '==========================================================='

postgres-create-table:
	@echo '__________________________________________________________'
	@echo 'Creating tables...'
	@echo '_________________________________________'
	@docker exec -it ${POSTGRES_CONTAINER_NAME} psql -U ${POSTGRES_USER} -d ${POSTGRES_DB} -f sql/Ecommerce.sql
	@echo '==========================================================='

postgres-ingest-csv:
	@echo '__________________________________________________________'
	@echo 'Ingesting CSV...'
	@echo '_________________________________________'
	@docker exec -it ${POSTGRES_CONTAINER_NAME} psql -U ${POSTGRES_USER} -d ${POSTGRES_DB} -f sql/Ingestdata.sql
	@echo '==========================================================='

postgres-run:
	@echo '__________________________________________________________'
	@echo 'run query
	...'
	@echo '_________________________________________'
	@docker exec -it ${POSTGRES_CONTAINER_NAME} psql -U ${POSTGRES_USER} -d ${POSTGRES_DB} -f sql/percobaan.sql
	@echo '==========================================================='

postgres-create-warehouse:
	@echo '__________________________________________________________'
	@echo 'Creating Warehouse DB...'
	@echo '_________________________________________'
	@docker exec -it ${POSTGRES_CONTAINER_NAME} psql -U ${POSTGRES_USER} -d ${POSTGRES_DB} -f sql/warehouse-ddl.sql
	@echo '==========================================================='

kafka: kafka-create

kafka-create:
	@echo '__________________________________________________________'
	@echo 'Creating Kafka Cluster ...'
	@echo '__________________________________________________________'
	@docker compose -f ./docker/docker-compose-kafka.yml --env-file .env up -d
	@echo 'Waiting for uptime on http://localhost:8083 ...'
	@sleep 20
	@echo '==========================================================='

kafka-create-test-topic:
	@docker exec ${KAFKA_CONTAINER_NAME} \
		kafka-topics.sh --create \
		--partitions 3 \
		--replication-factor ${KAFKA_REPLICATION} \
		--bootstrap-server localhost:9092 \
		--topic ${KAFKA_TOPIC_NAME}

kafka-create-topic:
	@docker exec ${KAFKA_CONTAINER_NAME} \
		kafka-topics.sh --create \
		--partitions ${partition} \
		--replication-factor ${KAFKA_REPLICATION} \
		--bootstrap-server localhost:9092 \
		--topic ${topic}

spark-produce:
	@echo '__________________________________________________________'
	@echo 'Producing fake events ...'
	@echo '__________________________________________________________'
	@docker exec ${SPARK_WORKER_CONTAINER_NAME}-1 \
		python \
		/spark-scripts/transform.py

spark-consume:
	@echo '__________________________________________________________'
	@echo 'Consuming fake events ...'
	@echo '__________________________________________________________'
	@docker exec ${SPARK_WORKER_CONTAINER_NAME}-1 \
		spark-submit \
		/spark-scripts/transform.py

datahub-create:
	@echo '__________________________________________________________'
	@echo 'Creating Datahub Instance ...'
	@echo '__________________________________________________________'
	@docker compose -f ./docker/docker-compose-datahub.yml --env-file .env up
	@echo '==========================================================='

docker-build-api-etl:
	@echo '__________________________________________________________'
	@echo 'Building Docker Images ...'
	@echo '__________________________________________________________'
	@docker network inspect rewastack-network >/dev/null 2>&1 || docker network create rewastack-network
	@echo '__________________________________________________________'
	@docker build -t mrewaakbari06/rewastack:api -f./docker/Dockerfile.uvicorn .
	@echo '__________________________________________________________'
	@docker build -t mrewaakbari06/rewastack:etl -f./docker/Dockerfile.etl .
	@echo '==========================================================='

api-etl:
	@echo '__________________________________________________________'
	@echo 'Creating API ETL Instance ...'
	@echo '__________________________________________________________'
	@docker compose -f ./docker/docker-compose-api-etl.yml up
	@echo '==========================================================='


metabase: postgres-create-warehouse
	@echo '__________________________________________________________'
	@echo 'Creating Metabase Instance ...'
	@echo '__________________________________________________________'
	@docker compose -f ./docker/docker-compose-metabase.yml --env-file .env up
	@echo '==========================================================='

clean:
	@bash ./scripts/goodnight.sh


postgres-bash:
	@docker exec -it dataeng-postgres bash