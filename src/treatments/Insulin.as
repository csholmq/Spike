package treatments
{
	public class Insulin
	{
		/* Properties */
		public var ID:String;
		public var name:String;
		public var dia:Number;
		public var type:String;
		public var isDefault:Boolean;
		public var timestamp:Number;
		public var isHidden:Boolean = false
		
		public function Insulin(id:String, name:String, dia:Number, type:String, isDefault:Boolean, timestamp:Number, isHidden:Boolean = false)
		{
			this.ID = id;
			this.name = name;
			this.dia = dia;
			this.type = type;
			this.isDefault = isDefault;
			this.timestamp = timestamp;
			this.isHidden = isHidden;
		}
	}
}