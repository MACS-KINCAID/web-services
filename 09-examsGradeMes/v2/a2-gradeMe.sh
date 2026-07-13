#!/bin/bash

source ./env

echo "Evaluando en puerto: ${PORT}"

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

BASE="http://localhost:${PORT}"
APP_CTRL="./src/app.controller.ts"
APP_SRV="./src/app.service.ts"
CTRL="./src/materias/materias.controller.ts"
SRV="./src/materias/materias.service.ts"
ATTR="misMaterias"

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
  local init_val=$(curl -s -X GET "$BASE/negativo")

  if [[ ! "$init_val" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
    echo "Not numerical value received: $init_val"
  fi

  init_val=$(printf "%g" "$init_val")


  check_request 200 "$((init_val - 1))" \
    -X GET "$BASE/negativo"
}

test_file() {
  if [[ ! -f "$1" ]]; then
    TEST_FAILED=1
    TEST_ERRORS+=("Missing file: $1")
  fi
}

test_attr() {
  match=$(grep -E -- "$1" "$2")

  if [[ -n "$match" ]]; then
    echo "Found: $match"
  else
    TEST_FAILED=1
    TEST_ERRORS+=("Missing "$1" in $2")
  fi
}

test_byTwo() {
  local rand1=$(rand -100 100)
  local rand2=$(rand -100 100)

  check_request 200 "$((rand1 * 2))" \
    -X GET "$BASE/byTwo?num=${rand1}"

  check_request 200 "$((rand2 * 2))" \
    -X GET "$BASE/byTwo?num=${rand2}"
}

test_demo() {
  check_request 201 "[\"Hola\",\"mundo\"]" \
    -X POST "$BASE/demo"
}

test_get_materias() {
  check_request 200 '\["(web|aprobada)","(calculo|aprobada)","(liderazgo|aprobada)"\]' \
    -X GET "$BASE/materias"
}

test_approve() {
  check_request 201 '\["aprobada","(calculo|aprobada)","(liderazgo|aprobada)"' \
    -X POST "$BASE/materias/aprobada/0"

  check_request 201 '\["aprobada","(calculo|aprobada)","aprobada"\]' \
    -X POST "$BASE/materias/aprobada/2"
}

test_reset_materias() {
  check_request 200 '["web","calculo","liderazgo"]' \
    -X PATCH "$BASE/materias/reset"

  check_request 201 '\["aprobada","(calculo|aprobada)","(liderazgo|aprobada)"' \
    -X POST "$BASE/materias/aprobada/0"

  check_request 201 '\["aprobada","(calculo|aprobada)","aprobada"\]' \
    -X POST "$BASE/materias/aprobada/2"

  check_request 200 '\["web","calculo","liderazgo"\]' \
    -X PATCH "$BASE/materias/reset"
}

test_exists() {
  local rand1=$(randstr 8)
  check_request 200 '\["web","calculo","liderazgo"\]' \
    -X PATCH "$BASE/materias/reset"

  check_request 200 'true' \
    -X GET "$BASE/materias/exists/web"

  check_request 200 'true' \
    -X GET "$BASE/materias/exists/calculo"

  check_request 200 'false' \
    -X GET "$BASE/materias/exists/operativos"

  check_request 200 'false' \
    -X GET "$BASE/materias/exists/${rand1}"
}

run_test "1. GET /byTwo?num=x" test_byTwo
run_test "1.1 this.<srv>.byTwo" test_attr "this\.[^.]+\.byTwo" "$APP_CTRL"
run_test "2. POST /demo" test_demo
run_test "2.1 this.<srv>.demo" test_attr "this\.[^.]+\.demo" "$APP_CTRL"
run_test "3. GET /materias" test_get_materias
run_test "4. POST /materias/aprobada/:index" test_approve
run_test "4.1 this.<srv>.setApproved" test_attr "this\.[^.]+\.setApproved" "$CTRL"
run_test "5. PATCH /materias/reset" test_reset_materias
run_test "6. GET /materias/exists/:materia" test_exists
run_test "6.1 this.<srv>.findSubject" test_attr "this\.[^.]+\.findSubject" "$CTRL"
#run_test "5. $CTRL exists" test_file "$CTRL"
#run_test "5. $SRV exists" test_file "$SRV"
#run_test "6. Searching '$ATTR'" test_attr $ATTR $SRV


