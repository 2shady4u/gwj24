extends "res://addons/gut/test.gd"

    
class TestFeatureA:
    extends 'res://addons/gut/test.gd'

    var Level = load('res://src/game/level/Level.gd')
    var _level = null

    func before_each():
        _level = Level.new()

    func after_each():
        _level = null

    func test_snapping_position():
        assert_eq(_level.get_snapped_position_in_grid(Vector2(0, 0)), Vector2(8, 8))
        assert_eq(_level.get_snapped_position_in_grid(Vector2(8, 8)), Vector2(8, 8))
        assert_eq(_level.get_snapped_position_in_grid(Vector2(8, 8) + Vector2(16, 0)), Vector2(24, 8))
