package basic_triangle

import rl "vendor:raylib"
import "vendor:raylib/rlgl"

main :: proc() {
	render_mode: i32 = rlgl.TRIANGLES
	handle_radius: f32 = 6

	starting_positions := [?]rl.Vector2 {{320, 150}, {220, 300}, {420, 300}}
	vertex_positions := starting_positions
	vertex_colors := [?]rl.Color {{255, 0, 0, 255}, {0, 255, 0, 255}, {0, 0, 255, 255}}
	assert(len(vertex_colors) == len(vertex_positions))
	
	handle_index := -1

	// Set window flag for anti-aliasing
	rl.SetConfigFlags({.MSAA_4X_HINT})
	rl.InitWindow(640, 480, "rlgl basic triangle")

	for !rl.WindowShouldClose() {
		mouse_position := rl.GetMousePosition()

		// If no handle has been selected
		if handle_index == -1 {
			// Check if the user is clicking on any of the handles, if so, store the index
			for position, i in vertex_positions {
				if rl.Vector2Distance(position, mouse_position) <= handle_radius {
					if rl.IsMouseButtonPressed(.LEFT) {
						handle_index = i
						break
					}
				}
			}
		} else {
			// Move selected vertex
			vertex_positions[handle_index] += rl.GetMouseDelta()

			// Deselect handle/vertex
			if rl.IsMouseButtonReleased(.LEFT) {
				handle_index = -1
			}
		}
		
		// Reset everything when the user presses "R"
		if rl.IsKeyPressed(.R) {
			vertex_positions = starting_positions

			handle_index = -1

			render_mode = rlgl.TRIANGLES
		}

		if rl.IsKeyPressed(.LEFT) {
			rlgl.EnableBackfaceCulling()
		}

		if rl.IsKeyPressed(.RIGHT) {
			rlgl.DisableBackfaceCulling()
		}

		// Update render mode
		if rl.IsKeyPressed(.SPACE) {
			// Toggle
			if render_mode == rlgl.TRIANGLES {
				render_mode = rlgl.LINES
			} else {
				render_mode = rlgl.TRIANGLES
			}
		}
		
		rl.BeginDrawing()
		rl.ClearBackground(rl.RAYWHITE)

		// Draw triangle
		rlgl.Begin(render_mode)
		switch render_mode {
			case rlgl.TRIANGLES:
				for position, i in vertex_positions {
					color := vertex_colors[i]
					rlgl.Color4ub(color.r, color.g, color.b, color.a)
					rlgl.Vertex2f(position.x, position.y)
				}

			case rlgl.LINES:
				for position, i in vertex_positions {
					color := vertex_colors[i]
					rlgl.Color4ub(color.r, color.g, color.b, color.a)
					if i != 0 {
						rlgl.Vertex2f(position.x, position.y)
					}
					rlgl.Vertex2f(position.x, position.y)
				}

				color := vertex_colors[0]
				position := vertex_positions[0]
				rlgl.Color4ub(color.r, color.g, color.b, color.a)
				rlgl.Vertex2f(position.x, position.y)
		}
		rlgl.End()

		// Draw handles
		for position, i in vertex_positions {
			if handle_index == i {
				rl.DrawCircleV(position, handle_radius, rl.Fade(rl.DARKGRAY, .8))
			} else if rl.Vector2Distance(position, rl.GetMousePosition()) <= handle_radius && handle_index == -1 {
				rl.DrawCircleV(position, handle_radius, rl.Fade(rl.DARKGRAY, .5))
			}

			rl.DrawCircleLinesV(position, handle_radius, {0, 0, 0, 127})
		}

		rl.DrawText("space to toggle lines\nleft/right enable/disable backface culling\nclick to drag points\nr to reset", 5, 5, 20, rl.DARKGRAY)
		rl.EndDrawing()
	}

	rl.CloseWindow()
}