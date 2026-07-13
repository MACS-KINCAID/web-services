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



test_vol() {
  local rand1=$(rand -100 100)
  local ans1=$(
    if (( ${rand1} % 2 == 0 || ${rand1} % 5 == 0 )); then
      echo "true"
    else
      echo "false"
    fi
  )
  local rand2=$(rand -100 100)
  local ans2=$(
    if (( ${rand2} % 2 == 0 || ${rand2} % 5 == 0 )); then
      echo "true"
    else
      echo "false"
    fi
  )

  check_request 200 "true" \
    -X PUT "$BASE/validVolume/8"

  check_request 200 "true" \
    -X PUT "$BASE/validVolume/15"

  check_request 200 "${ans1}" \
    -X PUT "$BASE/validVolume/${rand1}"

  check_request 200 "${ans2}" \
    -X PUT "$BASE/validVolume/${rand2}"
}

test_avg() {
  local rand1=$(rand -100 100)
  local rand2=$(rand -100 100)
  local rand3=$(rand -100 100)

  local rand4=$(rand -100 100)
  local rand5=$(rand -100 100)
  local rand6=$(rand -100 100)

  check_request 200 "$(((rand1 + rand2 + rand3)/3))" \
    -X PATCH "$BASE/avg?num1=${rand1}&num2=${rand2}&num3=${rand3}"

  check_request 200 "$(((rand4 + rand5 + rand6)/3))" \
    -X PATCH "$BASE/avg?num1=${rand4}&num2=${rand5}&num3=${rand6}"
}

test_cien() {
  local rand1=$(rand -100 100)
  local rand2=$(rand -100 100)
  local rand3=$(rand -100 100)

  check_request 200 "$(( 100 - rand1))" \
    -X GET "$BASE/cienMenos/${rand1}"

  check_request 200 "$(( 100 - rand2))" \
    -X GET "$BASE/cienMenos/${rand2}"

  check_request 200 "$(( 100 - rand3))" \
    -X GET "$BASE/cienMenos/${rand3}"
}

test_get_materias() {
  check_request 200 '\["(web|aprobada|reprobada)","(calculo|aprobada|reprobada)","(liderazgo|aprobada|reprobada)"\]' \
    -X GET "$BASE/materias"
}

test_setFail() {
  check_request 200 '\["reprobada","(calculo|aprobada|reprobada)","(liderazgo|aprobada|reprobada)"' \
    -X PATCH "$BASE/materias/reprobada/0"

  check_request 200 '\["reprobada","reprobada","(liderazgo|aprobada|reprobada)"\]' \
    -X PATCH "$BASE/materias/reprobada/1"

  check_request 200 '\["reprobada","reprobada","reprobada"\]' \
    -X PATCH "$BASE/materias/reprobada/2"
}

test_reset_materias() {
  check_request 200 '["web","calculo","liderazgo"]' \
    -X PATCH "$BASE/materias/reset"

  check_request 200 '\["reprobada","(calculo|aprobada|reprobada)","(liderazgo|aprobada|reprobada)"' \
    -X PATCH "$BASE/materias/reprobada/0"

  check_request 200 '\["reprobada","reprobada","(liderazgo|aprobada|reprobada)"\]' \
    -X PATCH "$BASE/materias/reprobada/1"

  check_request 200 '\["reprobada","reprobada","reprobada"\]' \
    -X PATCH "$BASE/materias/reprobada/2"

  check_request 200 '\["web","calculo","liderazgo"\]' \
    -X PATCH "$BASE/materias/reset"
}

run_test "1. PUT /validVolume/:num" test_vol
run_test "1.1 this.<srv>.validVolume" test_attr "this\.[^.]+\.validVolume" "$APP_CTRL"
run_test "2. PATCH /avg?num1=x&num2=y&num3=z" test_avg
run_test "2.1 this.<srv>.avg" test_attr "this\.[^.]+\.avg" "$APP_CTRL"
run_test "3. GET /cienMenos/:num1" test_cien
run_test "3.1 this.<srv>.cienMenos" test_attr "this\.[^.]+\.cienMenos" "$APP_CTRL"
run_test "4. GET /materias" test_get_materias
run_test "5. PATCH /materias/reprobada/:index" test_setFail
run_test "5.1 this.<srv>.setFailed" test_attr "this\.[^.]+\.setFailed" "$CTRL"
run_test "6. PATCH /materias/reset" test_reset_materias

#run_test "5. $CTRL exists" test_file "$CTRL"
#run_test "5. $SRV exists" test_file "$SRV"
#run_test "6. Searching '$ATTR'" test_attr $ATTR $SRV
