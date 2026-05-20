curl --request PUT \
  --url http://localhost:3000/objects/14 \
  --header 'content-type: application/json' \
  --data '{
  "name": "pablito",
  "data": {
    "testing": true
  }
}'
