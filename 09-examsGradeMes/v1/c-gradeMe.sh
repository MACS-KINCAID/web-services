#!/bin/bash

source ./env

echo "Evaluando en puerto: ${PORT}"

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

BASE="http://localhost:${PORT}"
CTRL="./src/movie/movie.controller.ts"
SRV="./src/movie/movie.service.ts"

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
    -X GET "$BASE/saludar/Mitsiu"

  check_request 200 "Hola Erik" \
    -X GET "$BASE/saludar/Erik"

  check_request 200 "Hola ${rand1}" \
    -X GET "$BASE/saludar/${rand1}"
}

test_mult() {
  local rand1=$(rand -100 100)
  local rand2=$(rand -100 100)

  check_request 200 "$((rand1 * 5))" \
    -X PUT "$BASE/multiplicar?a=${rand1}&b=5"

  check_request 200 "$((rand2 * 25))" \
    -X PUT "$BASE/multiplicar?a=${rand2}&b=25"

}

test_mayus() {
  local rand1=aaaaa$(randstr 8)
  local randLower1=$(node -e "console.log(process.argv[1].toUpperCase())" "$rand1")


  check_request 200 "GRITO" \
    -X PATCH "$BASE/mayus?mensaje=grito"

  check_request 200 "GRITO" \
    -X PATCH "$BASE/mayus?mensaje=GRITO"

  check_request 200 "${randLower1}" \
    -X PATCH "$BASE/mayus?mensaje=${rand1}"
}

test_asArray() {
  local rand1=AAA$(randstr)
  local rand2=BBB$(randstr)

  check_request 201 "[${rand1},Mitsiu]" \
    -X POST "$BASE/myFriends/Mitsiu/${rand1}"

  check_request 201 "[Mit,${rand2}]" \
    -X POST "$BASE/myFriends/${rand2}/Mit"
}

test_file() {
  if [[ ! -f "$1" ]]; then
    TEST_FAILED=1
    TEST_ERRORS+=("Missing file: $1")
  fi
}

test_attr() {
  match=$(grep -F 'myMovies' "$SRV")

  if [[ -n "$match" ]]; then
    echo "Found: $match"
  else
    TEST_FAILED=1
    TEST_ERRORS+=("Missing "myMovies" in ${SRV}")
  fi
}

test_get() {
  local rand1=AAA$(randstr)
  local rand2=BBB$(randstr)

  check_request 201 "${rand1}" \
    -X POST "$BASE/movies?title=${rand1}"

  check_request 200 "${rand1}" \
    -X GET "$BASE/movies"

  check_request 201 "${rand2}" \
    -X POST "$BASE/movies?title=${rand2}"

  check_request 200 "${rand2}" \
    -X GET "$BASE/movies"
}

test_get_index() {
  local rand1=CCC$(randstr)
  local rand2=DDD$(randstr)

  check_request 201 "${rand1}" \
    -X POST "$BASE/movies?title=${rand1}"

  check_request 201 "${rand2}" \
    -X POST "$BASE/movies?title=${rand2}"

  local init_val=$(curl -s -X GET "$BASE/movies")

  # Remove brackets
  init_val="${init_val#[}"
  init_val="${init_val%]}"

  # Split on commas
  IFS=',' read -r -a arr <<< "$init_val"

  if [[ -n "$arr[0]" ]]; then
    check_request 200 "${arr[0]//\"/}" \
      -X GET "$BASE/movies/search/0"
  else
    echo "FAILED POST /movies?title="
  fi

  if [[ -n "$arr[1]" ]]; then
    check_request 200 "${arr[1]//\"/}" \
      -X GET "$BASE/movies/search/1"
  else
    echo "FAILED POST /movies?title="
  fi
}

test_length() {
  local init_val=$(curl -s -X GET "$BASE/movies/size")

  if [[ ! "$init_val" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
    echo "Not numerical value received: $init_val"
  fi

  init_val=$(printf "%g" "$init_val")

  check_request 201 "qwerty" \
    -X POST "$BASE/movies?title=qwerty"

  check_request 200 "$((init_val + 1))" \
    -X GET "$BASE/movies/size"

  check_request 201 "asdf" \
    -X POST "$BASE/movies?title=asdf"

  check_request 200 "$((init_val + 2))" \
    -X GET "$BASE/movies/size"
}

run_test "1. GET /saludar/:nombre=" test_saludar
run_test "2. PUT /multiplicar?a=x&b=y" test_mult
run_test "3. PATCH /mayus?mensaje=" test_mayus
run_test "4. POST /myFriends/:nombre1/:nombre2" test_asArray
run_test "5. $CTRL exists" test_file "$CTRL"
run_test "5. $SRV exists" test_file "$SRV"
run_test "6. Searching 'myMovies'" test_attr
run_test "7,8. GET /movies POST /movies?title=" test_get
run_test "9. GET /movies/search/:index" test_get_index
run_test "10. GET /movies/size" test_length
