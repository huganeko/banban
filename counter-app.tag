<counter-app>

  <div class="count">
    <div>
      <span class="unit">今月</span>
      <span class="num">{ _func.getMonthBan() }</span>
      <span class="unit">バン</span>
    </div>
  </div>

  <div if="{ status.ban }" class="ban { status.show ? 'showing' : '' }">
    <img src="./assets/img/sperm.png">
  </div>

  <!-- 追加ボタン -->
  <button onclick="{ _func.countUp }" class="btn btn-default btn-lg btn-block ban-button">
    <img src="./assets/img/tissue.svg" width="75px" height="75px">
  </button>

  <hr>

  <canvas class="chart" id="{ uniqueId }">

  </canvas>
  <style scoped>

    .ban{
      position: fixed;
      height: 100%;
      width: 100%;
      display: flex;
      justify-content: center;
      align-items: center;
      background-color: rgba(240,240,240, .7);
      transition: opacity .25s;
      opacity: 0;
      top: 0;
      left: 0;
    }

    .showing{
      opacity: 1;
    }

    .ban > img{
      width: 90vw;
      height: 90vw;
      opacity: .4;
    }

    :scope{
      position: relative;
      display: block;
      height: 100%;
      width: 100%;
      border: 0;
      margin: 0;
      padding: 0;
    }
    .count{
      position: relative;
      margin: 0;
      padding: 0;
      display: flex;
      justify-content: center;
      align-items: center;
      width: 100%;
      height: 60vh;
    }

    #lineChart {
      position: absolute;
      width: 100%;
      height: 100%;
    }

    .ban-button{
      height: 40vh;
    }

    .num{
      color: #333;
      font-size: 48px;
      font-weight: bold;
      line-height: 1em;
      padding: 0;
      margin: 0;
    }
    .unit{
      color: #999;
      font-size: 18px;
      font-weight: bold;
      line-height: 1em;
      padding: 0;
      margin: 0 .2em;
    }

  </style>

  <script>
      var self = this;

      this.status = {
          ban : false,
          show : false
      };


      this.uniqueId = (function(){
          var strong = 1000;
          return 'a' + new Date().getTime().toString(16)  + Math.floor(strong*Math.random()).toString(16);
      })();


      this.cache = (localStorage.getItem('data3'))
          ? JSON.parse(localStorage.getItem('data3'))
          : (function(){
              var date = new Date();
              var year = date.getFullYear();
              var month = date.getMonth() + 1;
              var days = new Date(year, month, 0).getDate();
              var data = {};
              data[year] = {};
              data[year][month] = {};

              for(var i = 1; i <= days; i++){
                  data[year][month][i] = 0;
              }
              return data;
          })();


      this._func = {
          countUp : function(e){
              e.preventUpdate = true;

              var date = new Date();
              var year = date.getFullYear();
              var month = date.getMonth() + 1;
              var day = date.getDate();

              if(self.cache[year]){
                  if(self.cache[year][month]){
                      if(self.cache[year][month][day]){
                          self.cache[year][month][day]++;
                      } else{
                          self.cache[year][month][day] = 1;
                      }
                  } else{
                      self.cache[year][month] = {};
                      var days = new Date(year, month, 0).getDate();
                      for(var i = 1; i <= days; i++){
                          self.cache[year][month][i] = 0;
                      }
                      self.cache[year][month][day] = 1;
                  }
              } else{
                  self.cache[year] = {};
                  self.cache[year][month] = {};
                  var days = new Date(year, month, 0).getDate();
                  for(var i = 1; i <= days; i++){
                      self.cache[year][month][i] = 0;
                  }
                  self.cache[year][month][day] = 1;
              }

              self._func._save();
              self.status.show = false;
              self.status.ban = true;
              self.update();

              setTimeout(
                  function(){
                      self.status.show = true;
                      self.update();

                      setTimeout(
                          function(){
                              self.status.show = false;
                              self.update();

                              setTimeout(
                                  function(){
                                      self.status.ban = false;
                                      self.update();

                                      self._func.chart();
                                  }, 250
                              );
                          }, 250
                      );
                  },
                  10
              );
          },
          _save : function(){
              console.log("save");
              console.log(self.cache);
              localStorage.setItem('data3', JSON.stringify(self.cache));
          },
          chart : function(){
              var ctx = document.getElementById(self.uniqueId).getContext('2d');

              var date = new Date();
              var year = date.getFullYear();
              var month = date.getMonth() + 1;
              var days = (function(){return new Date(year, month, 0).getDate();})();
              var day = date.getDate();

              var label = (function(days){
                  var l = [];
                  for(var i = 1; i <= days; i++) l.push(i);
                  return l;
              })(days);

              console.log(label);

              var data = (function(data, days){
                  console.log(data);
                  var l = [];
                  for(var i = 1; i <= days; i++){
                      l.push(data[i]);
                  }
                  return l;
              })(self.cache[year][month], days);

              console.log(data);


              var chart = new Chart(ctx, {
                  type: 'line',
                  data: {
                      labels: label,
                      datasets: [{
                          label: '回数',
                          data: data,
                          borderWidth: 1
                      }]
                  },
                  options: {
                      scales: {
                          yAxes: [{
                              ticks: {
                                  beginAtZero:true,
                                  stepSize : 1
                              }
                          }]
                      }
                  }
              });
          },
          getMonthBan : function(){
              var date = new Date();
              var year = date.getFullYear();
              var month = date.getMonth() + 1;
              var day = date.getDate();

              if(self.cache[year]){
                  if(self.cache[year][month]){

                      var c = 0;
                      for(var d in self.cache[year][month]){
                          c += self.cache[year][month][d];
                      }
                      return c;
                  }
              }
              return 0;
          }
      }

      this.on('mount', self._func.chart);

  </script>

</counter-app>