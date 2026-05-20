curl --request POST \
  --url http://localhost:3000/objects \
  --header 'content-type: application/json' \
  --data '{
  "name": "mario",
  "test": "ok"
}'
