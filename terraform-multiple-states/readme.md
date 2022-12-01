```sh
# env=production
./run production network init
./run production network plan
./run production network apply

./run production compute init
./run production compute plan
./run production compute apply

./run production data init
./run production data plan
./run production data apply

./run production data destroy
./run production compute destroy
./run production network destroy
```

```sh
# env=staging
./run staging network init
./run staging network plan
./run staging network apply

./run staging compute init
./run staging compute plan
./run staging compute apply

./run staging datda init
./run staging datda plan
./run staging datda apply

./run staging network destroy
./run staging compute destroy
./run staging datda destroy
```
