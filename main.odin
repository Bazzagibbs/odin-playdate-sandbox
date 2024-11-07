package playdate_sandbox

import "base:runtime"
import "playdate"
import "core:math"
import "core:log"
import "core:fmt"

pd: ^playdate.Api
ctx: runtime.Context


Game_Data :: struct {
        counter : f32,
        bitmap : ^playdate.Bitmap,
}


@(export)
eventHandler :: proc "c" (pd_api: ^playdate.Api, event: playdate.System_Event, arg: u32) -> i32 {
        #partial switch event {
        case .Init:
                ctx = playdate.playdate_context_create(pd_api)
                context = ctx
                
                pd = pd_api

                game_data := new(Game_Data)
                game_data.bitmap = pd.graphics.new_bitmap(48, 48, {solid = .Black})

                pd.system.set_update_callback(update, game_data)

        case .Terminate:
                playdate.playdate_context_destroy(&ctx)
        }

        return 0;
}


update :: proc "c" (user_data: rawptr) -> playdate.Update_Result {
        context = ctx
        game_data := (^Game_Data)(user_data)
        
        pd.graphics.clear({solid = .White})
        pd.system.draw_fps(0, 0)

        midpoint := [2]i32 {playdate.LCD_COLUMNS, playdate.LCD_ROWS} / 2
        sin := math.sin(game_data.counter)
        width  := 120 + i32(sin * 30)
        height := 120 - i32(sin * 30)

        pd.graphics.draw_rect(
                x      = midpoint.x - width / 2,
                y      = midpoint.y - height / 2,
                width  = width,
                height = height,
                color  = {solid = .Black}
        )

        bitmap_scale_x := 1 - sin * 0.2
        bitmap_scale_y := 1 + sin * 0.2
        bitmap_width  := i32(48 * bitmap_scale_x)
        bitmap_height := i32(48 * bitmap_scale_y)

        pd.graphics.draw_scaled_bitmap(
                bitmap = game_data.bitmap,
                x = midpoint.x - bitmap_width / 2,
                y = midpoint.y - bitmap_height / 2,
                x_scale = bitmap_scale_x,
                y_scale = bitmap_scale_y,
        )

        game_data.counter += 0.1

        log.info(fmt.tprintf("%v", game_data.counter))

        return .Update_Display
}
