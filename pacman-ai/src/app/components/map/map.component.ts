import { Component, OnInit, HostListener } from '@angular/core';
import { HttpRequestService } from '../../services/http-request.service';
import { GameMap } from '../../models/game-map';
import { KEY_CODE } from '../../models/key.enum';
import { Position } from '../../models/position';
import { OBJECT_CODE } from '../../models/object.enum';
import { PREDICT_CODE } from '../../models/predict.enum';
import { GHOST_MOVE } from '../../models/ghost-move.enum';
import { Router } from '@angular/router';

@Component({
  selector: 'app-map',
  templateUrl: './map.component.html',
  styleUrls: ['./map.component.css']
})
export class MapComponent implements OnInit {

  map: GameMap = new GameMap([]);
  pacmanPosition: Position = new Position;
  ghostPosition: Position = new Position;

  constructor(private httpRequestService: HttpRequestService, private router: Router) {
    this.httpRequestService.getMap(10).subscribe(map => {
      this.map = new GameMap(map.rawMap);
      console.log(this.map)
      /*this.map.rawMap[1][3] = OBJECT_CODE.PACMAN;
      this.map.rawMap[2][5] = OBJECT_CODE.GHOST;*/

      this.pacmanPosition = this.map.getPosition(OBJECT_CODE.PACMAN);
      this.ghostPosition = this.map.getPosition(OBJECT_CODE.GHOST);
      console.log(this.pacmanPosition, this.ghostPosition);
    });
  }

  @HostListener('window:keyup', ['$event'])
  keyEvent(event: KeyboardEvent) {
    let x = this.pacmanPosition.x;
    let y = this.pacmanPosition.y;
    if (event.keyCode == KEY_CODE.DOWN_ARROW) {
      y++;
    } else if (event.keyCode == KEY_CODE.UP_ARROW) {
      y--;
    } else if (event.keyCode == KEY_CODE.LEFT_ARROW) {
      x--;
    } else if (event.keyCode == KEY_CODE.RIGHT_ARROW) {
      x++;
    } else {
      return;
    }

    console.log(x, y);
    console.log(this.map.rawMap[y][x])

    this.httpRequestService.getNextMove(x, y, this.map.rawMap[y][x])
      .subscribe(value => {
      console.log("getNextMove : ", value);
      switch (value.pred) {
        case PREDICT_CODE.OK:
          console.log("Tu peux avancer !");
          this.map.setTileValue(this.pacmanPosition, OBJECT_CODE.TILE);
          this.pacmanPosition.x = x;
          this.pacmanPosition.y = y;
          this.map.setTileValue(this.pacmanPosition, OBJECT_CODE.PACMAN);
          this.moveGhost();
          break;
        case PREDICT_CODE.KO:
          console.log("Ceci est un mur...");
          break;
        case PREDICT_CODE.VICTORY:
          console.log("Bravo !");
          this.router.navigate(['victory']);
          break;
        case PREDICT_CODE.GAME_OVER:
          console.log("Try again...");
          this.router.navigate(['gameover']);
          break;
      }
    });

  }


  private moveGhost() {
    this.httpRequestService.getGhostMove(this.map).subscribe(move => {
      console.log("getGhostMove : ", move);
      this.map.setTileValue(this.ghostPosition, OBJECT_CODE.TILE);
      if (move == GHOST_MOVE.UP) {
        this.ghostPosition.y--;
      } else if (move == GHOST_MOVE.DOWN) {
        this.ghostPosition.y++;
      } else if (move == GHOST_MOVE.LEFT) {
        this.ghostPosition.x--;
      } else if (move == GHOST_MOVE.RIGHT) {
        this.ghostPosition.x++;
      }
      this.map.setTileValue(this.ghostPosition, OBJECT_CODE.GHOST);
    });
  }

  ngOnInit() {

  }

}
