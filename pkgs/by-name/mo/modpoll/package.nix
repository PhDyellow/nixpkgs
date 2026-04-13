{ lib
, python3Packages
, fetchFromGitHub
, pre-commit
#, deptry
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "modpoll";
  version = "1.6.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "gavinying";
    repo = "${finalAttrs.pname}";
    rev = "v${finalAttrs.version}";
    hash = "sha256-qUnoRNe6MZLBN2gB35IzFgFCmqONUMkQPuWIQYDisrw=";
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
    pre-commit
    pytest
    # deptry
    tox
  ];

  disabledTests = [
    # Tests fail due to lack of network
    "test_mqtt_task_connect"
    "test_modbus_task_poll_modsim"
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
