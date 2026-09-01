"""Build reusable Guofeng UI textures from the supplied UI reference sheet."""

from __future__ import annotations

import argparse
import random
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter


GOLD = (190, 143, 75, 255)
GOLD_BRIGHT = (236, 194, 119, 255)
PANEL = (14, 24, 24, 244)
PANEL_INNER = (19, 33, 33, 238)


def warm_alpha(image: Image.Image, scale: int = 3) -> Image.Image:
	"""Keep the warm metallic ornament while discarding the baked dark backdrop."""
	source = image.convert("RGB")
	result = Image.new("RGBA", source.size)
	source_pixels = source.load()
	result_pixels = result.load()
	for y in range(source.height):
		for x in range(source.width):
			r, g, b = source_pixels[x, y]
			warmth = max(0, (r - g) * 4 + (g - b) * 3)
			brightness = max(0, r + g - b - 92)
			alpha = min(255, max(warmth, brightness) * 2)
			if alpha < 18:
				result_pixels[x, y] = (0, 0, 0, 0)
			else:
				result_pixels[x, y] = (r, g, b, alpha)
	result = result.resize((result.width * scale, result.height * scale), Image.Resampling.LANCZOS)
	return result.filter(ImageFilter.UnsharpMask(radius=1.4, percent=155, threshold=2))


def make_panel_texture(width: int, height: int, corners: dict[str, Image.Image]) -> Image.Image:
	rng = random.Random(width * 7919 + height)
	outer_inset = 8
	image = Image.new("RGBA", (width, height), (0, 0, 0, 0))
	pixels = image.load()
	for y in range(outer_inset, height - outer_inset):
		for x in range(outer_inset, width - outer_inset):
			grain = rng.randint(-5, 5)
			vignette = int(10 * max(abs(x - width * 0.5) / width, abs(y - height * 0.5) / height))
			pixels[x, y] = (max(0, 14 + grain - vignette), max(0, 24 + grain - vignette), max(0, 24 + grain - vignette), 245)
	draw = ImageDraw.Draw(image)
	draw.rectangle((outer_inset, outer_inset, width - outer_inset - 1, height - outer_inset - 1), outline=(190, 143, 75, 235), width=3)
	draw.rectangle((outer_inset + 6, outer_inset + 6, width - outer_inset - 7, height - outer_inset - 7), outline=(40, 49, 43, 220), width=2)
	corner_size = min(70, max(32, min(width - outer_inset * 2, height - outer_inset * 2) // 4))
	for key, position in {
		"tl": (outer_inset, outer_inset),
		"tr": (width - outer_inset - corner_size, outer_inset),
		"bl": (outer_inset, height - outer_inset - corner_size),
		"br": (width - outer_inset - corner_size, height - outer_inset - corner_size),
	}.items():
		corner = corners[key].resize((corner_size, corner_size), Image.Resampling.LANCZOS)
		image.alpha_composite(corner, position)
	return image


def make_button_texture(width: int, height: int, corners: dict[str, Image.Image], fill: tuple[int, int, int, int], border: tuple[int, int, int, int]) -> Image.Image:
	outer_inset = 8
	image = Image.new("RGBA", (width, height), (0, 0, 0, 0))
	draw = ImageDraw.Draw(image)
	draw.rounded_rectangle((outer_inset, outer_inset, width - outer_inset - 1, height - outer_inset - 1), radius=8, fill=fill, outline=border, width=3)
	draw.line((outer_inset + 14, outer_inset + 5, width - outer_inset - 14, outer_inset + 5), fill=(245, 211, 146, 110), width=1)
	corner_size = min(46, height - outer_inset * 2)
	for key, position in {
		"tl": (outer_inset, outer_inset),
		"tr": (width - outer_inset - corner_size, outer_inset),
		"bl": (outer_inset, height - outer_inset - corner_size),
		"br": (width - outer_inset - corner_size, height - outer_inset - corner_size),
	}.items():
		corner = corners[key].resize((corner_size, corner_size), Image.Resampling.LANCZOS)
		image.alpha_composite(corner, position)
	return image


def make_divider(width: int) -> Image.Image:
	image = Image.new("RGBA", (width, 42), (0, 0, 0, 0))
	draw = ImageDraw.Draw(image)
	center = width // 2
	draw.line((14, 21, center - 30, 21), fill=(183, 137, 77, 175), width=2)
	draw.line((center + 30, 21, width - 14, 21), fill=(183, 137, 77, 175), width=2)
	draw.line((24, 25, center - 36, 25), fill=(50, 64, 56, 210), width=1)
	draw.line((center + 36, 25, width - 24, 25), fill=(50, 64, 56, 210), width=1)
	draw.polygon([(center, 9), (center + 12, 21), (center, 33), (center - 12, 21)], outline=GOLD_BRIGHT, width=2)
	draw.ellipse((center - 4, 17, center + 4, 25), fill=(205, 154, 84, 245))
	return image


def make_bar_texture(width: int, height: int, corners: dict[str, Image.Image]) -> Image.Image:
	image = make_button_texture(width, height, corners, (8, 15, 16, 238), (172, 127, 70, 235))
	draw = ImageDraw.Draw(image)
	draw.rectangle((11, 11, width - 12, height - 12), outline=(44, 54, 49, 230), width=2)
	return image


def save_preview(output_dir: Path, names: list[str]) -> None:
	images = [Image.open(output_dir / name).convert("RGBA") for name in names]
	canvas = Image.new("RGBA", (1024, 760), (8, 14, 15, 255))
	positions = [(36, 36), (536, 36), (36, 358), (536, 358)]
	for image, position in zip(images, positions):
		preview = image.copy()
		preview.thumbnail((450, 290), Image.Resampling.LANCZOS)
		canvas.alpha_composite(preview, position)
	canvas.save(output_dir / "guofeng_ui_preview.png")


def main() -> None:
	parser = argparse.ArgumentParser()
	parser.add_argument("source", type=Path)
	parser.add_argument("output", type=Path)
	args = parser.parse_args()

	source = Image.open(args.source).convert("RGB")
	args.output.mkdir(parents=True, exist_ok=True)

	# The top corners come from the small confirmation panel. The lower corners
	# come from the upgrade panel so no baked-in button pixels enter the atlas.
	boxes = {
		"tl": (292, 256, 342, 306),
		"tr": (448, 256, 498, 306),
		"bl": (667, 459, 718, 510),
		"br": (975, 459, 1026, 510),
	}
	corners = {key: warm_alpha(source.crop(box)) for key, box in boxes.items()}
	for key, corner in corners.items():
		corner.save(args.output / f"ornament_corner_{key}.png")

	panel = make_panel_texture(768, 480, corners)
	panel.save(args.output / "panel_frame_2x.png")
	card = make_panel_texture(432, 600, corners)
	card.save(args.output / "upgrade_card_frame_2x.png")
	make_button_texture(384, 112, corners, (27, 38, 34, 246), (208, 162, 92, 245)).save(args.output / "button_normal_2x.png")
	make_button_texture(384, 112, corners, (34, 52, 49, 248), (244, 207, 135, 255)).save(args.output / "button_hover_2x.png")
	make_button_texture(384, 112, corners, (68, 48, 27, 250), (249, 214, 142, 255)).save(args.output / "button_pressed_2x.png")
	make_button_texture(384, 112, corners, (25, 32, 31, 232), (76, 86, 78, 210)).save(args.output / "button_disabled_2x.png")
	make_divider(512).save(args.output / "title_divider_2x.png")
	make_bar_texture(560, 48, corners).save(args.output / "hud_bar_frame_2x.png")

	save_preview(args.output, ["panel_frame_2x.png", "upgrade_card_frame_2x.png", "button_normal_2x.png", "hud_bar_frame_2x.png"])


if __name__ == "__main__":
	main()
