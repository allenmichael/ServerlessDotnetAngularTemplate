import { Component, OnInit, Inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { pipe } from 'rxjs';

@Component({
  selector: 'app-landing-page',
  templateUrl: './landing-page.component.html',
  styleUrls: ['./landing-page.component.css']
})
export class LandingPageComponent implements OnInit {
  apiUrl: string;
  weatherData = [];
  constructor(
    @Inject('API_URL') apiUrl: string,
    private http: HttpClient
  ) {
    this.apiUrl = apiUrl;
  }

  async ngOnInit() {
    this.http.get(`${this.apiUrl}api/SampleData/WeatherForecasts`)
      .subscribe(
        pipe((resp: any[]) => {
          console.log(resp);
          resp.map(v => {
            this.weatherData.push(v);
          });
        })
      );
  }

}
