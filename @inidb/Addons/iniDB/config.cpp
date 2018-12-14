class CfgPatches {
	class iniDB {
		units[] = {};
		weapons[] = {};
		requiredVersion = 0.1;
		requiredAddons[] = {};
		init = "call compile preprocessFileLineNumbers '\inidb\init.sqf'";
	};
};