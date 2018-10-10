import { Component, OnInit } from '@angular/core';
import { SquareComponent } from '../square/square.component';

@Component({
  selector: 'app-ghost',
  templateUrl: './ghost.component.html',
  styleUrls: ['./ghost.component.css']
})
export class GhostComponent extends SquareComponent implements OnInit {

  constructor() { 
    super();
  }

  ngOnInit() {
  }

}
