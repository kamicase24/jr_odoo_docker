# Docker 
Personal docker with odoo ready to use, install:
```
mv jr_odoo_docker project_name
cd project_name
docker image build --tag image_name .
docker-compose up -d
docker-compose exec -u root project bash
apt-get update -y && apt-get install -y libssl1.0-dev
exit
```
