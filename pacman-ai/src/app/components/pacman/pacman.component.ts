import { Component, OnInit } from '@angular/core';
import { SquareComponent } from '../square/square.component';

@Component({
  selector: 'app-pacman',
  templateUrl: './pacman.component.html',
  styleUrls: ['./pacman.component.css']
})
export class PacmanComponent extends SquareComponent implements OnInit {

  constructor() {
    super();
  }

  ngOnInit() {
  }

}
