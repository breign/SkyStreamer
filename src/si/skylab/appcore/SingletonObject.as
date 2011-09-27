package si.skylab.appcore
{
	import flash.utils.getQualifiedClassName;
	
	/**
	 * singleton for singletons
	 * 
	 * if you have SomeClass class like this:
	 * <pre>
	 * public class SomeClass extends Canvas
	 * {
	 *	public SomeClass()
	 *	{
	 *		super();
	 *	}
	 * 
	 * 	public function method1() : void
	 *  {
	 * 		AppFunctions.Log("singleton example.");
	 * 	}
	 * }
	 * </pre>
	 * 
	 * you can use SomeClass in the following way:
	 * <pre>
	 * var someSingleton : SomeClass = Singleton.getInstance(SomeClass) as SomeClass;
	 * 
	 * public function someMethod() : void
	 * {
	 * 	someSingleton.method1();
	 * }
	 * </pre>
	 * 
	 * or placed together in a Helper Class such as ApplicationHelper:
	 * <pre>
	 * public final class ApplicationHelper
	 * {
	 *  public function ApplicationHelper()
	 *  {
	 *   //
	 *  }
	 * 
	 *  public var someSingleton : SomeClass = Singleton.getInstance(SomeClass) as SomeClass;
	 *  //other singleton instance
	 * }
	 * </pre>
	 * 
	 * or call directly:
	 * <pre>
	 * Singleton.getInstance(SomeClass).method1();
	 * </pre>
	 * 
	 * how to use in mxml?
	 * You can register UIComponent in the <code>FlexEvent.INITIALIZE</code> event like this:
	 * <pre>
	 * <mx:TitleWindow xmlns:mx="http://www.adobe.com/2006/mxml">
	 * 
	 * 	<mx:initialize>
	 * 	<![CDATA[
	 * 		Singleton.register(this);
	 * 	]]>
	 * 	</mx:initialize>
	 * 
	 * <mx:Script>
	 * 	<![CDATA[
	 * 		import sban.fllib.patterns.Singleton;
	 * 	]]>
	 * </mx:Script>
	 * ...
	 * </mx:TitleWindow>
	 * </pre>
	 * 
	 * and then you can use Singleton as follow:
	 * <pre>
	 * var singleton : SingleWindow = Singleton.getInstance(SingleWindow) as SingleWindow;
	 * singleton.someMethod();
	 * </pre>
	 * 
	 *  
	 * @author sban.li
	 * 
	 */	
	public final class SingletonObject
	{
		/**
		 * @private 
		 */		
		private static var _instance : SingletonObject;
		
		/**
		 *  
		 * @param obj
		 * 
		 */		
		public static function register(obj : Object) : void
		{
			instance.register(obj);
		}
		
		/**
		 *  
		 * @param c
		 * @return 
		 * 
		 */		
		public static function getInstance(c : Class) : Object
		{
			return instance.getInstance(c);
		}
		
		/**
		 * 
		 * singleton for Singletons 
		 * @return 
		 * 
		 */		
		public static function get instance() : SingletonObject
		{
			return (_instance ||= new SingletonObject());
		}
		
		/**
		 * prevent to new outside 
		 * 
		 */		
		public function SingletonObject()
		{
			if (null != _instance)
			{
				throw new Error("Singleton can not be instantiated directly.");
			}else{
				_instance = this;
			}
		}
		
		/**
		* singletons collection
		*/	
		private var singletons : Object = {};
		
		/**
		 * clear all singleton instances.
		 * such as being used while scene changing in webgame
		 */		
		public function clear() : void
		{
			singletons = {};
		}
		
		/**
		 * register target as singleton 
		 * @param obj
		 * 
		 */		
		public function register(obj : Object) : void
		{
			var key : String = flash.utils.getQualifiedClassName(obj);
			
			if (!singletons[key]) singletons[key] = obj;
		}
		
		/**
		 * get instance, if not registered, register firstly.
		 * 
		 * @param c there is no arguments, or every argument have default value.
		 * @return 
		 * 
		 */		
		public function getInstance(c : Class) : Object
		{
			return (singletons[flash.utils.getQualifiedClassName(c)] ||= new c());
		}

	}
}
