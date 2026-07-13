#!/bin/bash

source ./env

echo "Evaluando en puerto: ${PORT}"

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

BASE="http://localhost:${PORT}"
CTRL="./src/integer/integer.controller.ts"
SRV="./src/integer/integer.service.ts"

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

  if [[ -n "$expected_body" ]] && ! grep -Fq -- "$expected_body" <<<"$body"; then
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

  local init_val=$(curl -s -X GET "$BASE/contador")

  if [[ ! "$init_val" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
    echo "Not numerical value received: $init_val"
  fi

  init_val=$(printf "%g" "$init_val")


  check_request 200 "$((init_val + 1))" \
    -X GET "$BASE/contador"

  check_request 200 "$((init_val + 2))" \
    -X GET "$BASE/contador"

  check_request 200 "$((init_val + 3))" \
    -X GET "$BASE/contador"
}

test_toggle() {
  check_request 200 "false" \
    -X PUT "$BASE/toggle/true"

  check_request 200 "true" \
    -X PUT "$BASE/toggle/false"

  #check_request 400 "boolean string is expected" \
  #  -X PUT "$BASE/toggle/1"

  #check_request 400 "boolean string is expected" \
  #  -X PUT "$BASE/toggle/a"
}

test_min() {
  check_request 200 "4" \
    -X PATCH "$BASE/min?num1=10&num2=9&num3=4"

  check_request 200 "-10" \
    -X PATCH "$BASE/min?num1=-10&num2=-9&num3=-4"

  check_request 200 "2" \
    -X PATCH "$BASE/min?num1=2&num2=2&num3=2"

  #check_request 400 "numeric string is expected" \
  #  -X PATCH "$BASE/min"

  #check_request 400 "numeric string is expected" \
  #  -X PATCH "$BASE/min?num1=a&num2=1&num2=2"
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
  match=$(grep -F 'myIntegers' "$SRV")

  if [[ -n "$match" ]]; then
    echo "Found: $match"
  else
    TEST_FAILED=1
    TEST_ERRORS+=("Missing "myIntegers" in ${SRV}")
  fi
}

test_get() {
  check_request 200 '[10,9,8,7' \
    -X GET "$BASE/integer"
}

test_add_int() {
  local rand1=$(rand 0 100)
  local rand2=$(rand 0 100)
  local rand3=$(rand 0 100)

  check_request 201 "${rand1}" \
    -X POST "$BASE/integer/${rand1}"

  check_request 201 "${rand2}" \
    -X POST "$BASE/integer/${rand2}"

  check_request 201 "${rand3}" \
    -X POST "$BASE/integer/${rand3}"
}

test_get_index() {
  check_request 200 "10" \
    -X GET "$BASE/integer/0"

  check_request 200 "9" \
    -X GET "$BASE/integer/1"

  check_request 200 "8" \
    -X GET "$BASE/integer/2"

  check_request 200 "7" \
    -X GET "$BASE/integer/3"
}

test_find() {
  local rand1=$(rand -300 -100)

  check_request 200 "encontrado" \
    -X GET "$BASE/integer/find/10"

  check_request 200 "encontrado" \
    -X GET "$BASE/integer/find/9"

  check_request 200 "encontrado" \
    -X GET "$BASE/integer/find/8"

  check_request 200 "encontrado" \
    -X GET "$BASE/integer/find/7"

  check_request 200 "no encontrado" \
    -X GET "$BASE/integer/find/${rand1}"
}

run_test "1. GET /contador" test_contador
run_test "2. PUT /toggle/:binario" test_toggle
run_test "3. PATCH /min" test_min
run_test "4. POST /favClass" test_favClass
run_test "5. $CTRL exists" test_file "$CTRL"
run_test "5. $SRV exists" test_file "$SRV"
run_test "6. Searching 'myIntegers'" test_attr
run_test "7. GET /integer" test_get
run_test "8. POST /integer/:newInteger" test_add_int
run_test "9. GET /integer/:index" test_get_index
run_test "10. GET /integer/find/:value" test_find
