import { Injectable } from '@angular/core';
import { Inject } from '@angular/core';
import { DOCUMENT } from '@angular/platform-browser';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs';
import { GameMap } from '../models/game-map';
import { PredictData } from '../models/predict-data';
import { OBJECT_CODE } from '../models/object.enum';
import { PREDICT_CODE } from '../models/predict.enum';
import { GHOST_MOVE } from '../models/ghost-move.enum';

@Injectable({
  providedIn: 'root'
})
export class HttpRequestService {
  private rootUrl_py = "http://localhost:5000";
  private rootUrl_R = "http://localhost:4242";
  private mapUrl = this.rootUrl_py + "/map";
  private predictUrl = this.rootUrl_py + "/predict";
  private ghostUrl = this.rootUrl_R + "/bot_next_move";
  private size: number;
  private iteration: number = 0;

  constructor(private http: HttpClient, @Inject(DOCUMENT) private document: any) {
    this.rootUrl_py = "http://"+document.location.hostname+":5000";
    this.rootUrl_R = "http://"+document.location.hostname+":4242";
    this.mapUrl = this.rootUrl_py + "/map";
    this.predictUrl = this.rootUrl_py + "/predict";
    this.ghostUrl = this.rootUrl_R + "/bot_next_move";
  }

  public getMap(size: number): Observable<GameMap> {
    this.size = 64;
    return this.http.get<GameMap>(this.mapUrl);
  }

  public getNextMove(x: number, y: number, cellValue: OBJECT_CODE): Observable<any> {
    let predict: PredictData = new PredictData();
    predict.pos_x = x;
    predict.pos_y = y;
    predict.ite = this.iteration;
    predict.board_size = this.size;
    predict.cell_value = cellValue-1;
    console.log(predict);
    this.iteration++;
    return this.http.post<any>(this.predictUrl, predict);
  }

  public getGhostMove(map:GameMap):Observable<GHOST_MOVE> {
    return this.http.post<GHOST_MOVE>(this.ghostUrl, map);
  }
}
