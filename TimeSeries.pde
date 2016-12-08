class TimeSeries
  {
     ArrayList Series;
     
     public TimeSeries()
       {
         Series = new ArrayList();
       }
       
     void Add( AssetDataFrame ADF )
       {
         Series.add( ADF );
       }
       
     double GetBid( int index )
       {
         return ( double ) ( ( ( AssetDataFrame ) Series.get( index ) ).GetBid() );
       }
       
     double GetAsk( int index )
       {
         return ( double ) ( ( ( AssetDataFrame ) Series.get( index ) ).GetAsk() );
       }
       
     Date GetDate( int index )
       {
         return ( Date ) ( ( ( AssetDataFrame ) Series.get( index ) ).get_date() );
       }
       
     double CorrelationPercentage( TimeSeries Asset, int index, int length )
       {
         double Rate = 0;
         
         for( int i = index; i < index+length; i++ )
           {
             if( ( ( Asset.GetBid( i ) > Asset.GetBid( i+1 ) ) && ( GetBid( i ) > GetBid( i+1 ) ) )
             || ( ( Asset.GetBid( i ) < Asset.GetBid( i+1 ) ) && ( GetBid( i ) < GetBid( i+1 ) ) ) )
               {
                 Rate += 1;
               }
           }
           
         return Rate/length;
       }
       
     double CorrelationCofficient( TimeSeries Asset, int index, int length )
       {
         double ssxy = 0;
         double ssxx = 0;
         double ssyy = 0;
         double Rate = 0;
         
         for( int i = index; i < index+length; i++ )
           {
             double delta_1 = GetBid( i );
             double delta_2 = Asset.GetBid( i );
             double mean_1 = Mean( index, length );
             double mean_2 = Asset.Mean( index, length );
             
             ssxy += ( delta_1-mean_1 )*( delta_2-mean_2 );
             ssxx += ( delta_1-mean_1 )*( delta_1-mean_1 );
             ssyy += ( delta_2-mean_2 )*( delta_2-mean_2 );
           }
           
         return ssxy/( double ) sqrt( ( float ) ( ssxx*ssyy ) );
       }
       
     double Mean( int index, int length )
       {
         double Rate = 0;
         
         for( int i = index; i < index+length; i++ )
           {
             Rate += GetBid( i );
           }
           
         return Rate/length;
       }
       
     double MeanRegression( int index, int length, int l2 )
       {
         double Rate = 0;
         
         for( int i = index; i < index+length; i++ )
           {
             Rate += ( ( Mean( i, l2 ) - Mean( length, l2 ) )/GetBid( index ) )/( length-i );
           }
           
         return Rate/length;
       }
       
     double StandardDeviation( int index, int length )
       {
         double Mean = Mean( index, length );
         
         double Rate = 0;
         
         for( int i = index; i < index+length; i++ )
           {
             Rate += ( double ) abs( ( float ) ( Mean - GetBid( i ) ) );
           }
           
         return Rate/length;
       }
       
     void DownloadInitialClaims()
       {
         Series = new ArrayList();
         
         send_get_fx( "https://api-fxtrade.oanda.com/labs/v1/calendar?instrument=EUR_USD&period=63072000");
         Object obj          = JSONValue.parse( returned_value );
         JSONArray calender     = ( JSONArray ) obj;
         
         for( int i = 0; i < calender.size(); i++ )
           {
             JSONObject event = ( JSONObject ) calender.get( i );
             
             if( ( ( String ) event.get( "title" ) ).equals( "Initial Claims" ) )
               {
                 AssetDataFrame _asset_ = new AssetDataFrame();
                 double ValueBid = Double.parseDouble( ( String ) event.get( "actual" ) );
                 double ValueAsk = Double.parseDouble( ( String ) event.get( "actual" ) );
                 String Day   = ( new Date() ).toString();
                 
                 _asset_.SetValues( Day, "Initial Claims", ValueBid, ValueAsk );
                 Add( _asset_ );
               }
           }
       }  
       
     void DownloadInitialClaimsForecast()
       {
         Series = new ArrayList();
         
         send_get_fx( "https://api-fxtrade.oanda.com/labs/v1/calendar?instrument=EUR_USD&period=63072000");
         Object obj          = JSONValue.parse( returned_value );
         JSONArray calender     = ( JSONArray ) obj;
         
         for( int i = 0; i < calender.size(); i++ )
           {
             JSONObject event = ( JSONObject ) calender.get( i );
             
             if( ( ( String ) event.get( "title" ) ).equals( "Initial Claims" ) )
               {
                 AssetDataFrame _asset_ = new AssetDataFrame();
                 double ValueBid = Double.parseDouble( ( String ) event.get( "market" ) );
                 double ValueAsk = Double.parseDouble( ( String ) event.get( "market" ) );
                 String Day   = ( new Date() ).toString();
                 
                 _asset_.SetValues( Day, "Initial Claims", ValueBid, ValueAsk );
                 Add( _asset_ );
               }
           }
       }
       
     void OandaDownloadHistory( String instrument, int count, String Gran )
       {
         Series = new ArrayList();
         
         send_get_fx( "https://api-fxtrade.oanda.com/v1/candles?instrument=" + instrument + "&count=" + count + "&candleFormat=bidask&granularity=" + Gran + "&dailyAlignment=0&alignmentTimezone=America%2FNew_York" );
          
         Object obj       = JSONValue.parse( returned_value );
          
         JSONObject TradeData = ( JSONObject ) obj;
         JSONArray candles = ( JSONArray ) TradeData.get( "candles" );
          
         for( int i = 0; i < count; i++ )
           {
             AssetDataFrame _asset_ = new AssetDataFrame();
             double ValueBid = Double.parseDouble( "" + ( ( JSONObject ) candles.get( count - 1 - i ) ).get( "openBid" ) );
             double ValueAsk = Double.parseDouble( "" + ( ( JSONObject ) candles.get( count - 1 - i ) ).get( "openAsk" ) );
             String Day   = ( String ) ( ( JSONObject ) candles.get( count - 1 - i ) ).get( "time" );
             
             _asset_.SetValues( Day, instrument, ValueBid, ValueAsk );
             Add( _asset_ );
           }
       }
  }

class AssetDataFrame
  {
    private String instrument_name;
    private Date   date;
    private double bid;
    private double ask;
    
    public AssetDataFrame()
      {
      }
      
    public void SetValues( String name, String _bid, String _ask )
      {
        instrument_name = name;
        date = new Date();
        bid  = Double.parseDouble( _bid );
        ask  = Double.parseDouble( _ask );
      }
      
    public void SetValues( String _time_, String name, double _bid, double _ask )
      {
        instrument_name = name;
        
        try
          {
            SimpleDateFormat formatter = new SimpleDateFormat("EEEE, MMM dd, yyyy HH:mm:ss a");
            date = formatter.parse( _time_ );
          }
        catch( Exception e )
          {
          }
          
        bid  = ( _bid );
        ask  = ( _ask );
      }
      
    public double GetBid()
      {
        return bid;
      }
    
    public double GetAsk()
      {
        return ask;
      }
      
    public String GetInstrument()
      {
        return instrument_name;
      }
      
    public Date get_date()
      {
        return date;
      }
  }
