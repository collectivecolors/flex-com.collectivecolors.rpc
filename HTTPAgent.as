package com.collectivecolors.rpc
{
	//----------------------------------------------------------------------------
	// Imports
		
	import com.collectivecolors.errors.InvalidInputError;
	
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
			
	//----------------------------------------------------------------------------
	
	public class HTTPAgent extends RemoteAgent
	{
		//--------------------------------------------------------------------------
		// Constants
		
		public static const METHOD_GET : String  = "GET";
		public static const METHOD_POST : String = "POST";
		
		public static const REQUEST_FORM : String = HTTPService.CONTENT_TYPE_FORM;
		public static const REQUEST_XML : String  = HTTPService.CONTENT_TYPE_XML;
		
		public static const RESULT_XML_OBJECT : String 
		  = HTTPService.RESULT_FORMAT_OBJECT;
		
		public static const RESULT_XML_ARRAY : String  
		  = HTTPService.RESULT_FORMAT_ARRAY;
		
		public static const RESULT_XML : String        
		  = HTTPService.RESULT_FORMAT_XML;
		
		public static const RESULT_XML_E4X : String    
		  = HTTPService.RESULT_FORMAT_E4X;
		
		public static const RESULT_TEXT : String       
		  = HTTPService.RESULT_FORMAT_TEXT;
		
		public static const RESULT_FLASHVARS : String  
		  = HTTPService.RESULT_FORMAT_FLASHVARS;
				
		//--------------------------------------------------------------------------
		// Properties
		
		private var _resultHandler : Function;
		
		protected var connection : HTTPService;
		        		
		//--------------------------------------------------------------------------
		// Constructor
		
		/**
		 * Constructor
		 * 
		 * Fault Handler Prototype
		 * -------------------------
		 * function someFunction( event : FaultEvent ) : void
		 */
		public function HTTPAgent( resultHandler : Function = null,
		                           faultHandler : Function  = null ) 
		{
			super( ( connection = new HTTPService( ) ), faultHandler );
			
			// Initialize remote connection.
			connection.method       = METHOD_GET;
			connection.contentType  = REQUEST_FORM;
			connection.resultFormat = RESULT_XML_OBJECT;
			
			connection.requestTimeout = 30;
					
			connection.addEventListener( ResultEvent.RESULT, requestResultHandler );
			
			// Initialize result handler.
			if ( resultHandler != null )
			{
				this.resultHandler = resultHandler;
			}			
		}		
		
		//--------------------------------------------------------------------------
		// Accessor / Modifiers
		
		/**
		 * Get remote result handler function
		 */
		public function get resultHandler( ) : Function
		{
			return _resultHandler;
		}
		
		/**
		 * Set remote result handler function 
		 * 
		 * Result Handler Prototype
		 * -------------------------
		 * function someFunction( event : ResultEvent ) : void
		 */				
		public function set resultHandler( value : Function ) : void 
		{
			if ( value == null )
			{
				throw new InvalidInputError( 
				  'Result handler function not specified' 
				);
			}
			
			_resultHandler = value;
		}
		
		//--------------------------------------------------------------------------
				
		/**
		 * Get remote connection method (GET or POST)
		 */
		public function get method( ) : String
		{
			return connection.method;
		}
		
		/**
		 * Set remote connection method (GET or POST) 
		 */				
		public function set method( value : String ) : void 
		{
			if ( value == null )
			{
				throw new InvalidInputError( 
				  'Remote connection method not specified'
				);
			}
			
			switch ( value )
			{
				case METHOD_GET:
				case METHOD_POST:
					break;
					
				default:
					throw new InvalidInputError( 
					  'Remote connection method not supported'
					);	
			}
			
			connection.method = value;
		}
		
		//--------------------------------------------------------------------------
				
		/**
		 * Get remote request type (FORM or XML)
		 */
		public function get requestType( ) : String
		{
			return connection.contentType;
		}
		
		/**
		 * Set remote request type (FORM or XML) 
		 */				
		public function set requestType( value : String ) : void 
		{
			if ( value == null )
			{
				throw new InvalidInputError( 
				  'Remote request type not specified'
				);
			}
			
			switch ( value )
			{
				case REQUEST_FORM:
				case REQUEST_XML:
					break;
					
				default:
					throw new InvalidInputError( 
					  'Remote request type not supported'
					);	
			}
			
			connection.contentType = value;
		}
		
		//--------------------------------------------------------------------------
				
		/**
		 * Get remote result type 
		 * 
		 * >-[ TEXT, XML, XML_OBJECT, XML_ARRAY, XML_E4X, or FLASHVARS ]
		 */
		public function get resultType( ) : String
		{
			return connection.resultFormat;
		}
		
		/**
		 * Set remote result type 
		 * 
		 * >-[ TEXT, XML, XML_OBJECT, XML_ARRAY, XML_E4X, or FLASHVARS ] 
		 */				
		public function set resultType( value : String ) : void 
		{
			if ( value == null )
			{
				throw new InvalidInputError( 
				  'Remote result type not specified'
				);
			}
			
			switch ( value )
			{
				case RESULT_TEXT:
				case RESULT_XML:
				case RESULT_XML_OBJECT:
				case RESULT_XML_ARRAY:
				case RESULT_XML_E4X:
				case RESULT_FLASHVARS:
					break;
					
				default:
					throw new InvalidInputError( 
					  'Remote result type not supported'
					);	
			}
			
			connection.resultFormat = value;
		}
		
		//--------------------------------------------------------------------------
		
		/**
		 * Get remote request timeout
		 */
		public function get timeout( ) : int
		{
			return connection.requestTimeout;
		}
		
		/**
		 * Set remote request timeout (in seconds)
		 */				
		public function set timeout( value : int ) : void 
		{
			if ( value < 0 )
			{
				throw new InvalidInputError( 
				  'Request timeout not a positive integer'
				);
			}
			
			connection.requestTimeout = value;
		}
		
		//--------------------------------------------------------------------------
		// Extensions
		
		/**
		 * Execute the HTTP service
		 */
		public function request( url : String, parameters : Object = null ) : void 
		{
			validateUrl( url, 
			  'Request endpoint is not a valid URL'
			);
			
			connection.url = url;
			connection.send( parameters );				
		}		
		
		//--------------------------------------------------------------------------
		// Event Handlers
		
		/**
		 * Remote result handler called after recieving intended results from 
		 * request
		 * 
		 * This function sets the operation status and statusMessage properties and
		 * then calls the specified remote result handler function with the given 
		 * result event from the HTTPService.
		 */
		protected function requestResultHandler( event : ResultEvent ) : void
		{
			message = 'Request completed successfully';
						
			if ( resultHandler != null ) 
			{
				resultHandler( event );
			}	
		}
	}
}