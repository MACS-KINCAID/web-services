#!/bin/bash

source ./env

echo "Evaluando en puerto: ${PORT}"

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

BASE="http://localhost:${PORT}"
CTRL="./src/tienda/tienda.controller.ts"
SRV="./src/tienda/tienda.service.ts"

rand() {
    local min="$1"
    local max="$2"
    local step="${3:-1}"

    awk -v min="$min" -v max="$max" -v step="$step" -v r="$RANDOM" '
    BEGIN {
        n = int((max - min) / step) + 1
        value = min + (r % n) * step

        # Print integers without decimals, floats with the right precision
        if (step == int(step))
            printf "%d\n", value
        else {
            decimals = length(step) - index(step, ".")
            printf "%.*f\n", decimals, value
        }
    }'
}

randstr() {
  local len="${1:-8}"
  tr -dc 'A-Za-z0-9' </dev/urandom | head -c "$len"
}

run_test() {
  local name="$1"
  shift

  TEST_FAILED=0
  TEST_ERRORS=()

  "$@"

  if (( TEST_FAILED == 0 )); then
    echo -e "${GREEN}✓ PASS${NC} [$name]\n\n"
  else
    echo -e "${RED}✗ FAIL${NC} [$name]"
    printf '    %s\n' "${TEST_ERRORS[@]}"
    echo -e "\n\n"
  fi
}

check_request() {
  local expected_status="$1"
  local expected_body="$2"
  shift 2

  local response body status

  echo $2 $3
  response=$(curl -s -w "|||%{http_code}" "$@")
  body="${response%|||*}"
  status="${response##*|||}"

  if [[ "$expected_body" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
    expected_body=$(printf "%g" "$expected_body")
  fi

  if [[ "$status" != "$expected_status" ]]; then
    TEST_FAILED=1
    TEST_ERRORS+=("REQ: $3")
    TEST_ERRORS+=("└──Expected status $expected_status, got $status")
  fi

  if [[ -n "$expected_body" ]] && ! grep -Eq -- "$expected_body" <<<"$body"; then
    TEST_FAILED=1
    TEST_ERRORS+=("REQ: $3")
    TEST_ERRORS+=("├──Body did not contain '$expected_body'")
    TEST_ERRORS+=("└──Body: $body")
  fi
}

test_contador() {
  #check_request 201 "created" \
  #  -X POST "$BASE/users" \
  #  -d '{"name":"John"}'

  local init_val=$(curl -s -X GET "$BASE/negativo")

  if [[ ! "$init_val" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
    echo "Not numerical value received: $init_val"
  fi

  init_val=$(printf "%g" "$init_val")


  check_request 200 "$((init_val - 1))" \
    -X GET "$BASE/negativo"

  check_request 200 "$((init_val - 2))" \
    -X GET "$BASE/negativo"

  check_request 200 "$((init_val - 3))" \
    -X GET "$BASE/negativo"
}

test_par() {
  local rand1=$(rand -100 100)

  check_request 200 "par" \
    -X PUT "$BASE/esPar/10"


  check_request 200 "impar" \
    -X PUT "$BASE/esPar/11"

  check_request 200 "(par|impar)" \
    -X PUT "$BASE/esPar/${rand1}"
}

test_max() {
  check_request 200 "10" \
    -X PATCH "$BASE/max?num1=10&num2=9&num3=4"

  check_request 200 "-4" \
    -X PATCH "$BASE/max?num1=-10&num2=-9&num3=-4"

  check_request 200 "2" \
    -X PATCH "$BASE/max?num1=2&num2=2&num3=2"
}

test_favClass() {
  check_request 201 '["APLICACIONES","WEB","ORIENTADAS","A","SERVICIOS"]' \
    -X POST "$BASE/favClass"
}


test_file() {
  if [[ ! -f "$1" ]]; then
    TEST_FAILED=1
    TEST_ERRORS+=("Missing file: $1")
  fi
}

test_attr() {
  match=$(grep -F 'misArticulos' "$SRV")

  if [[ -n "$match" ]]; then
    echo "Found: $match"
  else
    TEST_FAILED=1
    TEST_ERRORS+=("Missing "myMovies" in ${SRV}")
  fi
}

test_get() {
  check_request 200 '\["(frijoles|vendido)","(papitas|vendido)","(pan|vendido)","(galletas|vendido)"' \
    -X GET "$BASE/tienda"
}

test_comprar() {
  check_request 201 '\["vendido"' \
    -X POST "$BASE/tienda/comprar/0"

  check_request 201 '\["vendido","vendido"' \
    -X POST "$BASE/tienda/comprar/1"

  check_request 201 '\["vendido","vendido","vendido"' \
    -X POST "$BASE/tienda/comprar/2"
}

test_restock() {
  local rand1=AAA$(randstr 8)
  local rand2=BBB$(randstr 8)

  check_request 201 "${rand1}" \
    -X POST "$BASE/tienda?nuevoArt=${rand1}"

  check_request 201 "${rand2}" \
    -X POST "$BASE/tienda?nuevoArt=${rand2}"
}

test_find() {
  local rand1=CCC$(randstr 8)
  local rand2=DDD$(randstr 8)
  local rand3=EEE$(randstr 8)

  check_request 201 "${rand1}" \
    -X POST "$BASE/tienda?nuevoArt=${rand1}"

  check_request 200 "true" \
    -X GET "$BASE/tienda/find/${rand1}"

  check_request 201 "${rand2}" \
    -X POST "$BASE/tienda?nuevoArt=${rand2}"

  check_request 200 "true" \
    -X GET "$BASE/tienda/find/${rand2}"

  check_request 200 "false" \
    -X GET "$BASE/tienda/find/${rand3}"
}

run_test "1. GET /negativo" test_contador
run_test "2. PUT /esPar/:num" test_par
run_test "3. PATCH /max?num1=x&num2=y&num3=z" test_max
run_test "4. POST /favClass" test_favClass
run_test "5. $CTRL exists" test_file "$CTRL"
run_test "5. $SRV exists" test_file "$SRV"
run_test "6. Searching 'misArticulos'" test_attr
run_test "7. GET /tienda" test_get
run_test "8. POST /tienda/comprar/:index" test_comprar
run_test "9. POST /tienda?nuevoArt=" test_restock
run_test "10. GET /tienda/find/:value" test_find
