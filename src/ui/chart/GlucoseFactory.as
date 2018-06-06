package ui.chart
{
	import flash.errors.IllegalOperationError;
	import flash.system.Capabilities;
	
	import spark.formatters.DateTimeFormatter;
	
	import G5Model.TransmitterStatus;
	
	import database.BgReading;
	import database.BlueToothDevice;
	import database.Calibration;
	import database.CommonSettings;
	import database.Sensor;
	
	import model.ModelLocator;
	
	import ui.InterfaceController;
	
	import utils.TimeSpan;
	
	[ResourceBundle("chartscreen")]
	[ResourceBundle("transmitterscreen")]

	public class GlucoseFactory
	{
		public function GlucoseFactory()
		{
			throw new IllegalOperationError("GlucoseFactory class is not meant to be instantiated!");
		}
		
		public static function getGlucoseOutput(glucoseValue:Number):Object
		{
			var glucoseUnit:String;
			if (CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_DO_MGDL) == "true") 
				glucoseUnit = "mg/dL";
			else
				glucoseUnit = "mmol/L";
			
			var glucoseOutput:String;
			var glucoseValueFormatted:Number;
			if (glucoseValue > 40 && glucoseValue < 400)
			{
				if (glucoseUnit == "mg/dL")
				{
					if (CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_CHART_ROUND_MGDL_ON) != "true")
						glucoseValueFormatted = Math.round(glucoseValue * 10) / 10;
					else
						glucoseValueFormatted = Math.round(glucoseValue);
					glucoseOutput = String( glucoseValueFormatted );
				}
				else
				{
					glucoseValueFormatted = Math.round(BgReading.mgdlToMmol(glucoseValue) * 10) / 10;
					
					if ( glucoseValueFormatted % 1 == 0)
						glucoseOutput = String(glucoseValueFormatted) + ".0";
					else
						glucoseOutput = String(glucoseValueFormatted);
				}
			}
			else
			{
				if (glucoseUnit == "mg/dL")
				{
					if (CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_CHART_ROUND_MGDL_ON) != "true")
						glucoseValueFormatted = Math.round(glucoseValue * 10) / 10;
					else
						glucoseValueFormatted = Math.round(glucoseValue);
				}
				else
					glucoseValueFormatted = Math.round(BgReading.mgdlToMmol(glucoseValue) * 10) / 10;
				
				if (glucoseValue >= 400)
					glucoseOutput = ModelLocator.resourceManagerInstance.getString('chartscreen','glucose_high');
				else if (glucoseValue <= 40 && glucoseValue > 12)
					glucoseOutput = ModelLocator.resourceManagerInstance.getString('chartscreen','glucose_low');
				else
				{
					switch(glucoseValue) {
						case 0:
							glucoseOutput = "??0";
							break;
						case 1:
							glucoseOutput = "?SN";
							break;
						case 2:
							glucoseOutput = "??2";
							break;
						case 3:
							glucoseOutput = "?NA";
							break;
						case 5:
							glucoseOutput = "?NC";
							break;
						case 6:
							glucoseOutput = "?CD";
							break;
						case 9:
							glucoseOutput = "?AD";
							break;
						case 12:
							glucoseOutput = "?RF";
							break;
						default:
							glucoseOutput = "???";
							break;
					}
				}
			}
			
			return {glucoseOutput: glucoseOutput, glucoseValueFormatted: glucoseValueFormatted};
		}
		
		public static function getGlucoseSlope(previousGlucoseValue:Number, previousGlucoseValueFormatted:Number, glucoseValue:Number, glucoseValueFormatted:Number):String
		{
			var glucoseUnit:String;
			if (CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_DO_MGDL) == "true") 
				glucoseUnit = "mg/dL";
			else
				glucoseUnit = "mmol/L";
			
			var slopeOutput:String;
			var glucoseDifference:Number;
			
			if (glucoseUnit == "mg/dL")
				glucoseDifference = Math.round((glucoseValueFormatted - previousGlucoseValueFormatted) * 10) / 10;
			else
			{
				glucoseDifference = Math.round(((Math.round(BgReading.mgdlToMmol(glucoseValue) * 100) / 100) - (Math.round(BgReading.mgdlToMmol(previousGlucoseValue) * 100) / 100)) * 100) / 100;
				
			}
				
			if((glucoseUnit == "mg/dL" && Math.abs(glucoseDifference) > 100) || (glucoseUnit == "mmol/L" && Math.abs(glucoseDifference) > 5.5))
				slopeOutput = ModelLocator.resourceManagerInstance.getString('chartscreen','slope_error');
			else
			{
				var glucoseDifferenceOutput:String;
				
				if (glucoseDifference >= 0)
				{
					glucoseDifferenceOutput = String(glucoseDifference);
						
					if ( glucoseDifference % 1 == 0 && (!BlueToothDevice.isFollower() && CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_FOLLOWER_MODE) != "Nightscout"))
						glucoseDifferenceOutput += ".0";
						
					slopeOutput = "+ " + glucoseDifferenceOutput;
				}
				else
				{
					glucoseDifferenceOutput = String(Math.abs(glucoseDifference));
						
					if ( glucoseDifference % 1 == 0 && (!BlueToothDevice.isFollower() && CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_FOLLOWER_MODE) != "Nightscout"))
						glucoseDifferenceOutput += ".0";
						
					slopeOutput = "- " + glucoseDifferenceOutput;
				}
			}
			
			return slopeOutput;
		}
		
		public static function getGlucoseColor(glucoseValue:Number):uint
		{
			//Colors
			var highUrgentGlucoseMarkerColor:uint = uint(CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_CHART_URGENT_HIGH_COLOR));
			var highGlucoseMarkerColor:uint = uint(CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_CHART_HIGH_COLOR));
			var inrangeGlucoseMarkerColor:uint = uint(CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_CHART_IN_RANGE_COLOR));
			var lowGlucoseMarkerColor:uint = uint(CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_CHART_LOW_COLOR));
			var lowUrgentGlucoseMarkerColor:uint = uint(CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_CHART_URGENT_LOW_COLOR));
			
			//Threshold
			var glucoseUrgentLow:Number = Number(CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_URGENT_LOW_MARK));
			var glucoseLow:Number = Number(CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_LOW_MARK));
			var glucoseHigh:Number = Number(CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_HIGH_MARK));
			var glucoseUrgentHigh:Number = Number(CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_URGENT_HIGH_MARK));
			
			var color:uint;
			if(glucoseValue >= glucoseUrgentHigh)
				color = highUrgentGlucoseMarkerColor;
			else if(glucoseValue >= glucoseHigh)
				color = highGlucoseMarkerColor;
			else if(glucoseValue > glucoseLow && glucoseValue < glucoseHigh)
				color = inrangeGlucoseMarkerColor;
			else if(glucoseValue <= glucoseLow && glucoseValue > glucoseUrgentLow)
				color = lowGlucoseMarkerColor;
			else if(glucoseValue <= glucoseUrgentLow)
				color = lowUrgentGlucoseMarkerColor;
			
			return color;
		}
		
		public static function formatIOB(IOBValue:Number):String
		{
			var value:String = String(IOBValue);
			var valueLength:int = value.length;
			var decimalPosition:int = -1;
			if (value.indexOf(".") != -1)
				decimalPosition = value.indexOf(".");
			if (value.indexOf(",") != -1)
				decimalPosition = value.indexOf(",");
			
			if (decimalPosition != -1 && decimalPosition == valueLength - 2)
				value = value + "0";
			else if (decimalPosition == -1 && valueLength == 1 && IOBValue != 0)
				value = value + ".00";
			else if (IOBValue == 0)
				value = "0.00";
			
			value += "U";
			
			return value;
		}
		public static function formatCOB(COBValue:Number):String
		{
			var value:String = String(COBValue);
			var valueLength:int = value.length;
			var decimalPosition:int = -1;
			if (value.indexOf(".") != -1)
				decimalPosition = value.indexOf(".");
			if (value.indexOf(",") != -1)
				decimalPosition = value.indexOf(",");
			
			if (decimalPosition == -1 && COBValue != 0)
				value = value + ".0";
			else if (COBValue == 0)
				value = "0.0";
			
			value += "g";
			
			return value;
		}
		
		public static function getRawGlucose():Number 
		{
			var raw:Number = Number.NaN;
			var lastBgReading:BgReading = BgReading.lastNoSensor();
			var lastCalibration:Calibration = Calibration.last();
			if (lastBgReading != null && lastCalibration != null)
			{
				var slope:Number = lastCalibration.checkIn ? lastCalibration.slope : 1000/lastCalibration.slope;
				var scale:Number = lastCalibration.checkIn ? lastCalibration.firstScale : 1;
				var intercept:Number = lastCalibration.checkIn ? lastCalibration.firstIntercept : lastCalibration.intercept * -1000 / lastCalibration.slope;
				var unfiltered:Number = lastBgReading.usedRaw() * 1000;
				var filtered:Number = lastBgReading.ageAdjustedFiltered() * 1000;
				
				if (slope === 0 || unfiltered === 0 || scale === 0) 
					raw = 0;
				else if (filtered === 0 || lastBgReading.calculatedValue < 40) 
					raw = scale * (unfiltered - intercept) / slope;
				else 
				{
					var ratio:Number = scale * (filtered - intercept) / slope / lastBgReading.calculatedValue;
					raw = scale * (unfiltered - intercept) / slope / ratio;
				}
				
				if (!isNaN(raw) && raw != 0)
				{
					if (CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_DO_MGDL) == "true")
					{
						if (CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_CHART_ROUND_MGDL_ON) != "true")
							raw = Math.round(raw * 10) / 10;
						else
							raw = Math.round(raw);
					}
					else
						raw = Math.round(BgReading.mgdlToMmol(raw) * 10) / 10;
				}
			}
			
			return raw;
		}
		
		public static function getSensorAge():String
		{
			var sage:String = "N/A";
			
			if (Sensor.getActiveSensor() != null)
			{
				var dateFormatter:DateTimeFormatter = new DateTimeFormatter();
				dateFormatter.dateTimePattern = "dd MMM HH:mm";
				dateFormatter.useUTC = false;
				dateFormatter.setStyle("locale",Capabilities.language.substr(0,2));
				
				//Set sensor start time
				var sensorStartDate:Date = new Date(Sensor.getActiveSensor().startedAt)
				var sensorStartDateValue:String =  dateFormatter.format(sensorStartDate);
				
				//Calculate Sensor Age
				var sensorDays:String;
				var sensorHours:String;
				
				if (BlueToothDevice.knowsFSLAge()) 
				{
					var sensorAgeInMinutes:String = CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_FSL_SENSOR_AGE);
					
					if (sensorAgeInMinutes == "0") 
						sage = ModelLocator.resourceManagerInstance.getString('sensorscreen', "sensor_age_not_applicable");
					else if ((new Number(sensorAgeInMinutes)) > 14.5 * 24 * 60) 
					{
						sage = ModelLocator.resourceManagerInstance.getString('sensorscreen','sensor_expired');
					}
					else 
					{
						sensorDays = TimeSpan.fromMinutes(Number(sensorAgeInMinutes)).days.toString();
						sensorHours = TimeSpan.fromMinutes(Number(sensorAgeInMinutes)).hours.toString();
						
						sage = sensorDays + "d " + sensorHours + "h";
					}
				}
				else
				{
					var nowDate:Date = new Date();
					sensorDays = TimeSpan.fromDates(sensorStartDate, nowDate).days.toString();
					sensorHours = TimeSpan.fromDates(sensorStartDate, nowDate).hours.toString();
					
					sage = sensorDays + "d " + sensorHours + "h";
				}
			}
			
			return sage;
		}
		
		public static function getTransmitterBattery():Object
		{
			var transmitterBatteryColor:uint = 0xEEEEEE;
			var transmitterBattery:String;
			var transmitterValue:Number = Number.NaN;
			var transmitterNameValue:String = BlueToothDevice.known() ? BlueToothDevice.name : ModelLocator.resourceManagerInstance.getString('transmitterscreen','device_unknown');
			
			if (BlueToothDevice.isDexcomG5())
			{
				var voltageAValue:String = CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_G5_VOLTAGEA);
				if (voltageAValue == "unknown" || transmitterNameValue == ModelLocator.resourceManagerInstance.getString('transmitterscreen','device_unknown')) voltageAValue = ModelLocator.resourceManagerInstance.getString('transmitterscreen','battery_unknown');
				
				var voltageBValue:String = CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_G5_VOLTAGEB);
				if (voltageBValue == "unknown" || transmitterNameValue == ModelLocator.resourceManagerInstance.getString('transmitterscreen','device_unknown')) voltageBValue = ModelLocator.resourceManagerInstance.getString('transmitterscreen','battery_unknown');
				
				var resistanceValue:String = CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_G5_RESIST);
				if (resistanceValue == "unknown" || transmitterNameValue == ModelLocator.resourceManagerInstance.getString('transmitterscreen','device_unknown')) resistanceValue = ModelLocator.resourceManagerInstance.getString('transmitterscreen','battery_unknown');
				
				transmitterBattery = "A: " + voltageAValue + ", B: " + voltageBValue + ", R: " + resistanceValue;
				
				if (!isNaN(Number(voltageAValue)))
				{
					if (Number(voltageAValue) < G5Model.TransmitterStatus.LOW_BATTERY_WARNING_LEVEL_VOLTAGEA)
						transmitterBatteryColor = 0xff1c1c;
					else
						transmitterBatteryColor = 0x4bef0a;
				}
			}
			else if (BlueToothDevice.isDexcomG4()) 
			{
				transmitterBattery = CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_G4_TRANSMITTER_BATTERY_VOLTAGE);
				
				if (transmitterBattery.toUpperCase() == "0" || transmitterBattery.toUpperCase() == "UNKNOWN" || transmitterNameValue == ModelLocator.resourceManagerInstance.getString('transmitterscreen','device_unknown')) 
					transmitterBattery = ModelLocator.resourceManagerInstance.getString('transmitterscreen','battery_unknown');
				
				transmitterValue = Number(CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_G4_TRANSMITTER_BATTERY_VOLTAGE))
				
				if (!isNaN(transmitterValue))
				{
					if (transmitterValue >= 213)
						transmitterBatteryColor = 0x4bef0a;
					else if (transmitterValue > 210)
						transmitterBatteryColor = 0xff671c;
					else
						transmitterBatteryColor = 0xff1c1c;
				}
					
			}
			else if (BlueToothDevice.isBlueReader())
			{
				transmitterBattery = CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_BLUEREADER_BATTERY_LEVEL);
				
				if (transmitterBattery == "0" || transmitterNameValue == ModelLocator.resourceManagerInstance.getString('transmitterscreen','device_unknown')) 
					transmitterBattery = ModelLocator.resourceManagerInstance.getString('transmitterscreen','battery_unknown');
				else
					transmitterBattery = String(Number(CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_BLUEREADER_BATTERY_LEVEL)))  + "%";
				
				transmitterValue = Number(CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_BLUEREADER_BATTERY_LEVEL))
				
				if (!isNaN(transmitterValue))
				{
					if (transmitterValue >= 60)
						transmitterBatteryColor = 0x4bef0a;
					else if (transmitterValue > 30)
						transmitterBatteryColor = 0xff671c;
					else
						transmitterBatteryColor = 0xff1c1c;
				}
			}
			else if (BlueToothDevice.isTransmiter_PL())
			{
				transmitterBattery = CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_BLUEREADER_BATTERY_LEVEL);
				
				if (transmitterBattery == "0" || transmitterNameValue == ModelLocator.resourceManagerInstance.getString('transmitterscreen','device_unknown')) 
					transmitterBattery = ModelLocator.resourceManagerInstance.getString('transmitterscreen','battery_unknown');
				else
					transmitterBattery = String(CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_BLUEREADER_BATTERY_LEVEL) + "%");
				
				transmitterValue = Number(CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_BLUEREADER_BATTERY_LEVEL))
				
				if (!isNaN(transmitterValue))
				{
					if (transmitterValue >= 60)
						transmitterBatteryColor = 0x4bef0a;
					else if (transmitterValue > 30)
						transmitterBatteryColor = 0xff671c;
					else
						transmitterBatteryColor = 0xff1c1c;
				}
			}
			else if (BlueToothDevice.isMiaoMiao())
			{
				transmitterBattery = CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_MIAOMIAO_BATTERY_LEVEL);
				
				if (transmitterBattery == "0" || transmitterNameValue == ModelLocator.resourceManagerInstance.getString('transmitterscreen','device_unknown')) 
					transmitterBattery = ModelLocator.resourceManagerInstance.getString('transmitterscreen','battery_unknown');
				else
					transmitterBattery = String(CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_MIAOMIAO_BATTERY_LEVEL) + "%");
				
				transmitterValue = Number(CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_MIAOMIAO_BATTERY_LEVEL))
				
				if (!isNaN(transmitterValue))
				{
					if (transmitterValue >= 60)
						transmitterBatteryColor = 0x4bef0a;
					else if (transmitterValue > 30)
						transmitterBatteryColor = 0xff671c;
					else
						transmitterBatteryColor = 0xff1c1c;
				}
			}
			else if (BlueToothDevice.isBluKon())
			{
				transmitterBattery = CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_BLUKON_BATTERY_LEVEL) + "%";
				if (transmitterBattery == "0" || transmitterNameValue == ModelLocator.resourceManagerInstance.getString('transmitterscreen','device_unknown') || !InterfaceController.peripheralConnected)
					transmitterBattery = ModelLocator.resourceManagerInstance.getString('transmitterscreen','battery_unknown');
				
				transmitterValue = Number(CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_BLUKON_BATTERY_LEVEL))
				
				if (!isNaN(transmitterValue))
				{
					if (transmitterValue >= 60)
						transmitterBatteryColor = 0x4bef0a;
					else if (transmitterValue > 30)
						transmitterBatteryColor = 0xff671c;
					else
						transmitterBatteryColor = 0xff1c1c;
				}
			}
			else if (BlueToothDevice.isLimitter())
			{
				transmitterBattery = CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_BLUEREADER_BATTERY_LEVEL);
				if (transmitterBattery == "0" || transmitterNameValue == ModelLocator.resourceManagerInstance.getString('transmitterscreen','device_unknown')) 
					transmitterBattery = ModelLocator.resourceManagerInstance.getString('transmitterscreen','battery_unknown');
				else
					transmitterBattery = String((Number(CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_BLUEREADER_BATTERY_LEVEL)))/1000);
				
				transmitterValue = Number(CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_BLUEREADER_BATTERY_LEVEL))
				
				if (!isNaN(transmitterValue))
				{
					if (transmitterValue >= 60)
						transmitterBatteryColor = 0x4bef0a;
					else if (transmitterValue > 30)
						transmitterBatteryColor = 0xff671c;
					else
						transmitterBatteryColor = 0xff1c1c;
				}
			}
			
			if (transmitterBattery == null || transmitterBattery == "")
				transmitterBattery = ModelLocator.resourceManagerInstance.getString('transmitterscreen','battery_unknown');	
			
			return { level: transmitterBattery, color: transmitterBatteryColor };
		}
	}
}