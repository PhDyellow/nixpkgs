{ lib
, python3Packages
, fetchFromGitHub
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "modpoll";
  version = "1.6.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "gavinying";
    repo = "${finalAttrs.pname}";
    rev = "v${finalAttrs.version}";
    hash = lib.fakeHash;
  };

  build-system = with python3Packages; [
    poetry-core

  ];

  dependencies = with python3Packages; [
    pymodbus
    paho-mqtt
    prettytable
    requests
    pyserial

    # requirements.txt not in above
    certifi
    charset-normalizer
    idna
    urllib3
    wcwidth

    # pyproject dev dependencies
    # pre-commit
    pytest
    deptry
    tox
  ];

  meta = {
    changelog = "https://github.com/gavinying/modpoll/releases/tag/v${finalAttrs.version}";
    description = "Modpoll - A New Command-line Tool for Modbus and MQTT";
    homepage = "https://github.com/gavinying/modpoll";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [
      phdyellow
    ];
  };
})
