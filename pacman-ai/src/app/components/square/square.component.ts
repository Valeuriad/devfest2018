import { Component, OnInit, Optional } from '@angular/core';

@Component({
  selector: 'app-square',
  templateUrl: './square.component.html',
  styleUrls: ['./square.component.css']
})
export class SquareComponent implements OnInit {

  constructor(@Optional() private _color: string = "#000000") { }

  get color(): string {
    return this._color;
  }

  set color(color: string) {
    this._color = color;
  }

  ngOnInit() {
  }

}
