build-monitoring:
	docker-compose -f docker/monitoring-dc.yml build

start-monitoring:
	docker-compose -f docker/monitoring-dc.yml up -d

build-blockchain:
	docker-compose -f docker/blockchain-dc.yml build

start-blockchain:
	docker-compose -f docker/blockchain-dc.yml up -d --scale full_node=3

start-logs:
	docker compose -f docker/blockchain-dc.yml logs discovery_node full_node --follow

start: start-monitoring start-blockchain start-logs

stop-monitoring:
	docker-compose -f docker/blockchain-dc.yml down

stop-blockchain:
	docker-compose -f docker/blockchain-dc.yml down --remove-orphans

stop: stop-monitoring stop-blockchain

run: stop start
