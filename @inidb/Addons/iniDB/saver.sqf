private ["_saveToDB","_array","_varName","_varValue","_saveArray","_loadFromDB","_type","_loadArray", "_uid","_player"];
//CHANGE PUBLICVARSERVER TO CLIENTS OR ALL
//CHANGE 2nd uid to side in future
_saveToDB =
"
	_uid = _this select 0;
	_varName = _this select 1;
	_varValue = _this select 2;
	_saveArray = [_uid, _uid, _varName, _varValue];
	_saveArray call iniDB_write;
";

saveToDB = compile _saveToDB;

_aggSaveToDB =
"
	_uid = _this select 0;
	{
		if ((_forEachIndex > 0) && (typeName _x == 'ARRAY')) then {
			_varName = _x select 0;
			_varValue = _x select 1;
			_saveArray = [_uid, _uid, _varName, _varValue];
			_saveArray call iniDB_write;
		};
	} forEach _this;
";

aggSaveToDB = compile _aggSaveToDB;

_loadFromDB =
"
	_array = _this;
	_player = owner (_this select 0);
	_uid = _array select 1;
	_varName = _array select 2;
	_varType = _array select 3;
	if ([_uid] call accountExists) then {
		_loadArray = [_uid, _uid, _varName, _varType];
		accountToClient = [_uid, _varName, _loadArray call iniDB_read];
		_player publicVariableClient 'accountToClient';
	}
";

loadFromDB = compile _loadFromDB;

_accountExists =
"
	_uid = _this select 0;
	_exists = _uid call iniDB_exists;
	_exists
";
accountExists = compile _accountExists;

"accountToServerSave" addPublicVariableEventHandler
{
	(_this select 1) spawn saveToDB;
};

"accountToServerAggSave" addPublicVariableEventHandler
{
	(_this select 1) call aggSaveToDB;
};

"accountToServerLoad" addPublicVariableEventHandler
{
	(_this select 1) spawn loadFromDB;
};

player_save_dc = {
	private["_player"]; 
	_player = _this select 0;
	_uid = _this select 1;
	if (not([_player] call player_exists)) exitWith {};
	switch ([_player] call player_side) do
	{
		private "_suffix";
		case west:
		{
			_suffix = "West";
		};
		case east:
		{
			_suffix = "East";
		};
		case resistance:
		{
			_suffix = "Res";
		};
		case civilian:
		{
			_suffix = "Civ";
		};
		[_uid, "moneyAccount" + _suffix, ([_player] call get_bank_valuez)] call _saveToDB; 
		[_uid, "MagazinesPlayer" + _suffix, magazines _player] call _saveToDB; 
		if(count ([_player, "INV_LicenseOwner"] call player_get_array) > 0) then {
			[_uid, "Licenses" + _suffix, [_player, "INV_LicenseOwner"] call player_get_array] call _saveToDB; 
		};
		[_uid, "Inventory" + _suffix, ([_player] call player_get_inventory)] call _saveToDB; 
		[_uid, "privateStorage" + _suffix, ([_player, "private_storage"] call player_get_array)] call _saveToDB; 
		[_uid, "Factory" + _suffix, [_player, "INV_Fabrikowner"] call player_get_array] call _saveToDB; 
		[_uid, "WeaponsPlayer" + _suffix, weapons _player] call _saveToDB; 
		[_uid, "positionPlayer" + _suffix, ASLtoATL (getPosASL _player)] call _saveToDB; 
		[_uid, "BackpackPlayer" + _suffix, typeOf unitBackpack _player] call _saveToDB; 
		[_uid, "BackWepPlayer" + _suffix, getWeaponCargo (unitBackpack _player)] call _saveToDB;
		[_uid, "BackMagPlayer" + _suffix, getMagazineCargo (unitBackpack _player)] call _saveToDB;
	};
};

serverSaveFunctionsLoaded = 1;