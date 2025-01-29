isudo sysctl -w vm.max_map_count=262144

cd ~/src
git clone https://github.com/infiniflow/ragflow.git
cd ragflow/docker
chmod +x ./entrypoint.sh
docker compose up -d

