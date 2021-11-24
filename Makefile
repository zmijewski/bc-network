build-monitoring:
	docker-compose -f docker/monitoring-dc.yml build

start-monitoring:
	docker-compose -f docker/monitoring-dc.yml up -d

build-blockchain:
	docker-compose -f docker/blockchain-dc.yml build

start-blockchain:
	docker-compose -f docker/blockchain-dc.yml up --scale full_node=3

start: start-monitoring start-blockchain

stop-monitoring:
	docker-compose -f docker/blockchain-dc.yml down

stop-blockchain:
	docker-compose -f docker/blockchain-dc.yml down --remove-orphans

stop: stop-monitoring stop-blockchain

run: stop start
