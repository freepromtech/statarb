class AlertSystem
  {
    int Second;
    int Cummulative;
    
    public AlertSystem()
      {
        Second = second();
        Cummulative = 0;
      }
      
    void Update()
      {
        if( second() != Second )
          {
            if( second()-Second > 0 )
              {
                Cummulative += second() - Second;
              }
              
            Second = second();
          }
      }
      
    boolean CheckLevel( int LVL )
      {
        if( LVL <= Cummulative )
          {
            Cummulative = 0;
            return true;
          }
        else
          {
            return false;
          }
      }
  }
