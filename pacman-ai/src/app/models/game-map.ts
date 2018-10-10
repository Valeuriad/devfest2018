import { Position } from "./position";
import { OBJECT_CODE } from "./object.enum";

export class GameMap {
    rawMap:number[][] = [];

    constructor(rawIn:number[][]) {
        this.rawMap = rawIn;
    }

    public getPosition (object:OBJECT_CODE):Position  {
        let result:Position = new Position();
        let y = 0;

        for(let lines of this.rawMap) {
            let x: number = 0;
            for(let col of lines) {
                if(col == object) {
                    result.x=x;
                    result.y=y;
                    return result;
                }
                x++;
            }
            y++;
        }
        return null;
    }

    public setTileValue(pos:Position, value:OBJECT_CODE) {
        this.rawMap[pos.y][pos.x] = value;
    }
}
