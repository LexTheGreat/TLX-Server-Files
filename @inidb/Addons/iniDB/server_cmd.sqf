#include "debug_console.hpp"

"serverLogger" addPublicVariableEventHandler {
	_debugTest = format["%1", _this select 1];
	diag_log _debugTest;
	conFileTime(_debugTest);
};
"serverFlagSet" addPublicVariableEventHandler {
	((_this select 1) select 0) setFlagTexture ((_this select 1) select 1);
};
"serverFpsBroadcast" addPublicVariableEventHandler {
	[_this select 1] spawn {
		_this = _this select 0;

		srvFpsCheck = _this select 1;
		_this = _this select 0;
		_this = owner _this;

		if (typeName _this != "SCALAR") then {
			_this = parseNumber (str _this);
		};
		if (!srvFpsCheck) then {
			srvFpsCheck = true;
			_this publicVariableClient "srvFpsCheck";
			while {srvFpsCheck} do {
				serverFPS = [diag_fps, diag_fpsmin];
				_this publicVariableClient "serverFPS";
				sleep 1;
			};	
		}
		else {
			srvFpsCheck = false;
			_this publicVariableClient "srvFpsCheck";
		};
	};
};

