package com.as3mxml.asconfigc.utils
{
	public function populateHTMLTemplateFile(content:String, options:Object):String
	{
		if(options === null)
		{
			return content;
		}
		for(var key:String in options)
		{
			var token:String = "${" + key + "}";
			var value:String = options[key];
			var index:int = content.indexOf(token);
			while(index !== -1)
			{
				content = content.substr(0, index) + value + content.substr(index + token.length);
				index = content.indexOf(token);
			}
		}
		return content;
	}
}