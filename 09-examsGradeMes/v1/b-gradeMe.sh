#!/bin/bash

source ./env

echo "Evaluando en puerto: ${PORT}"

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

BASE="http://localhost:${PORT}"
CTRL="./src/boolean/boolean.controller.ts"
SRV="./src/boolean/boolean.service.ts"

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

test_saludar() {
  local rand1=AAAA$(randstr 8)

  check_request 200 "Hola Mitsiu" \
    -X GET "$BASE/saludar?nombre=Mitsiu"

  check_request 200 "Hola Erik" \
    -X GET "$BASE/saludar?nombre=Erik"

  check_request 200 "Hola ${rand1}" \
    -X GET "$BASE/saludar?nombre=${rand1}"
}

test_sumar() {
  local rand1=$(rand -100 100)
  local rand2=$(rand -100 100)

  check_request 200 "$((rand1 + 5 + 10))" \
    -X PUT "$BASE/sumar?num1=${rand1}&num2=5&num3=10"

  check_request 200 "$((rand2 + 50 + 25))" \
    -X PUT "$BASE/sumar?num1=${rand2}&num2=50&num3=25"

}

test_minus() {
  local rand1=AAAA$(randstr 8)
  local randLower1=$(node -e "console.log(process.argv[1].toLowerCase())" "$rand1")


  check_request 200 "secreto" \
    -X PATCH "$BASE/minus?mensaje=secreto"

  check_request 200 "secreto" \
    -X PATCH "$BASE/minus?mensaje=SECRETO"

  check_request 200 "${randLower1}" \
    -X PATCH "$BASE/minus?mensaje=${rand1}"
}

test_asArray() {
  local rand1=$(rand -100 100)
  local rand2=$(rand -100 100)

  check_request 201 "[8,${rand1}]" \
    -X POST "$BASE/asArray/8/${rand1}"

  check_request 201 "[${rand2},12]" \
    -X POST "$BASE/asArray/${rand2}/12"
}

test_file() {
  if [[ ! -f "$1" ]]; then
    TEST_FAILED=1
    TEST_ERRORS+=("Missing file: $1")
  fi
}

test_attr() {
  match=$(grep -F 'myBooleans' "$SRV")

  if [[ -n "$match" ]]; then
    echo "Found: $match"
  else
    TEST_FAILED=1
    TEST_ERRORS+=("Missing "myIntegers" in ${SRV}")
  fi
}

test_get() {
  check_request 200 '\[(true|false),(true|false),(true|false),(true|false)\]' \
    -X GET "$BASE/boolean"
}

test_update() {
  check_request 201 '\[true,' \
    -X POST "$BASE/boolean/true/0"

  check_request 201 '\[true,true,' \
    -X POST "$BASE/boolean/true/1"

  check_request 201 '\[true,true,true' \
    -X POST "$BASE/boolean/true/2"
}

test_get_index() {
  check_request 201 '\[true,' \
    -X POST "$BASE/boolean/true/0"

  check_request 201 '\[true,true,' \
    -X POST "$BASE/boolean/true/1"

  check_request 201 '\[true,true,true' \
    -X POST "$BASE/boolean/true/2"

  check_request 201 '\[true,true,true,true' \
    -X POST "$BASE/boolean/true/3"

  check_request 200 "true" \
    -X GET "$BASE/boolean/myBool/0"

  check_request 200 "true" \
    -X GET "$BASE/boolean/myBool/1"

  check_request 200 "true" \
    -X GET "$BASE/boolean/myBool/2"

  check_request 200 "true" \
    -X GET "$BASE/boolean/myBool/3"
}

test_all_true() {
  check_request 201 '\[true,' \
    -X POST "$BASE/boolean/true/0"

  check_request 201 '\[true,true,' \
    -X POST "$BASE/boolean/true/1"

  check_request 201 '\[true,true,true' \
    -X POST "$BASE/boolean/true/2"

  check_request 201 '\[true,true,true,true' \
    -X POST "$BASE/boolean/true/3"

  check_request 200 "true" \
    -X GET "$BASE/boolean/allTrue"
}


run_test "1. GET /saludar?nombre=" test_saludar
run_test "2. PUT /sumar?num1=x&num2=y&num3=z" test_sumar
run_test "3. PATCH /minus?mensaje=" test_minus
run_test "4. POST /asArray/:num1/:num2" test_asArray
run_test "5. $CTRL exists" test_file "$CTRL"
run_test "5. $SRV exists" test_file "$SRV"
run_test "6. Searching 'myBooleans'" test_attr
run_test "7. GET /boolean" test_get
run_test "8. POST /boolean/true/:index" test_update
run_test "9. GET /boolean/myBool/:index" test_get_index
run_test "10. GET /boolean/allTrue" test_all_true
