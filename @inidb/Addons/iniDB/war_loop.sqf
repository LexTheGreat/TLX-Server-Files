//server globalChat "War Loop Loaded";
private ["_warloop"];
_warloop = '
//format[""server globalChat"info 1 = %1 i 2 je %2";"", _this select 0, _this select 1] call broadcast;
	private ["_doWar", "_warTime", "_timeNow", "_westTime", "_westCaps", "_eastTime", "_eastCaps"];
	_doWar = _this select 1;
	if(_doWar) then {
		warstatus = true;
		publicVariable "warstatus";
		format["server globalChat ""TLA has declared war against the North!"";"] call broadcast;
		format["hint ""****War has been declared by the TLA****"";"] call broadcast;
		
		warstatusopf = true;
		publicVariable "warstatusopf";
		warstatuscop = true;
		publicVariable "warstatuscop";
		peacecomps = false;
		publicVariable "peacecomps";
		_warTime = floor(time);
		_westTime = 0;
		_eastTime = 0;
		for "_y" from 0 to 3600 step 1 do {
			_timeNow = floor(time);
			//format["player globalChat""warstatus loop started  y is at %1\n time is at %2"";", _y, _time] call broadcast;
			if(_y < 1800) then {
				if(!warstatusopf && !warstatuscop || (_timeNow - _warTime) >= 1800) then {
					_y = 1800;
					_warTime = _timeNow;
				};
				_westCaps = [west] call zone_getCount;
				_westTime = [_westCaps, _westTime, _timeNow, _y, "NATO"]  call warWinnerCheck;
				_eastCaps = [east] call zone_getCount;
				_eastTime = [_eastCaps, _eastTime, _timeNow, _y, "TLA"]  call warWinnerCheck;
				if(_westTime == -1) then {
					format["
					[] spawn
					{
						if (!iscop) exitWith {};
						_cash = ((playersNumber east)*250000 + 1500000); 
						player commandChat format [""America and its allies are once more victorious in liberating and bringing democracy to a third world country, which just so happens to have oil... and lots of it. The Federal Reserve has printed and given you %1 dollars"", _cash];
						[player, ""money"", _cash] call INV_AddInventoryItem;
					};
					"] call broadcast;

					_y = 1801;
				};
				if(_eastTime == -1) then {
						format["
					[] spawn
					{
						if (!isopf) exitWith {};
						_cash = ((playersNumber west)*250000 + 1500000); 
						player commandChat format [""The TLA stands victorious against the imperialist Americans. Our Russian comrades have sent us %1 dollars in foreign aid, so that the crimson banner may yet keep waving."", _cash];
						[player, ""money"", _cash] call INV_AddInventoryItem;
					};
					"] call broadcast;
					_y = 1801;
				};
				
			}//don't add semi colon due to else
			else {
				if ((_timeNow - _warTime) >= 1800) then {
					_y = 3600;
				};
				if(_y == 3600) then {
					warstatus = false;
					publicVariable "warstatus";
				};
			};
			if(_y == 1800) then {
				peacecomps = true;
				publicVariable "peacecomps";
				warstatusopf = false;
				publicVariable "warstatusopf";
				warstatuscop = false;
				publicVariable "warstatuscop";
				format["player globalChat ""TLA and North have signed a ceasefire after a stalemate!"";"] call broadcast;
				format["player globalChat ""30-minute ceasefire cooldown before the next war can commence"";"] call broadcast;
				format["hint ""WAR IS OVER, 30-minute ceasefire is now in effect"";"] call broadcast;
				_bluZone = ["bluforZone"] call zone_getOwner;
				_opfZone = ["opforZone"] call zone_getOwner;
				_resZone = ["indepZone"] call zone_getOwner;
				if (_bluZone == west || _bluZone == east) then {
					["bluforZone", civilian, bluforZoneFlag,"bluforFlag"] call zone_setOwner;
				};
				if (_opfZone == west || _opfZone == east) then {
					["opforZone", civilian, opforZoneFlag,"opforFlag"] call zone_setOwner;
				};
				if (_resZone == west || _resZone == east) then {
					["indepZone", civilian, indepZoneFlag,"indepFlag"] call zone_setOwner;
				};
			};
			
			sleep 1;
		};
	};
';
warloop = compile _warloop;
"warstatus" addPublicVariableEventHandler {
	_this spawn warloop;
};

warWinnerCheck = {

_caps = _this select 0;
_time = _this select 1;
_timeNow = _this select 2;
_y = _this select 3;
_faction = _this select 4;

if (_caps == 3) then {
	if (_time == 0) then {
		_time = _timeNow + 120;
	}
	else {
		if ((_time - _timeNow) <= 0) then {
			peacecomps = true;
			publicVariable "peacecomps";
			warstatusopf = false;
			publicVariable "warstatusopf";
			warstatuscop = false;
			publicVariable "warstatuscop";
			format["player globalChat ""%1 has won the war and forced its enemies to surrender!"";", _faction] call broadcast;
			format["player globalChat ""30-minute ceasefire cooldown before the next war can commence"";"] call broadcast;
			format["hint ""WAR IS OVER, 30-minute ceasefire is now in effect"";"] call broadcast;
			['opforZone', civilian, opforZoneFlag,'opforFlag'] call zone_setOwner;
			['indepZone', civilian, indepZoneFlag,'indepFlag'] call zone_setOwner;
			['bluforZone', civilian, bluforZoneFlag,'bluforFlag'] call zone_setOwner;
			_time = -1;
		}
		else {
			if(_y % 10 == 0) then {						
				format["
					[] spawn
					{
						if (isciv) exitWith {};
						hint ""%1 has control of all 3 warzones, and will win the war if it holds them for %2 more server seconds \n(NOTE: server seconds = 2-4 real time seconds depending on server load)"";
					};
				", _faction,(_time - _timeNow)] call broadcast;
			};
		};
	};
}
else {
	_time = 0;
};
_time
};


