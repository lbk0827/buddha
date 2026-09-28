from pathlib import Path

from PIL import Image, ImageChops, ImageFilter


ROOT = Path(r"C:\src\bucheo_handsome")
OUT = ROOT / "Imgs"
GEN = Path(
    r"C:\Users\Admin\.codex\generated_images"
    r"\01a0e6f9-37aa-7642-9bcf-e7d51bfbb220"
)

BASE = OUT / "base_saffron.png"

BASE_VARIANTS = {
    "base_temple.png": GEN / "exec-00ed9d84-c3cd-4c86-a296-a32427a861b7.png",
    "base_ash.png": GEN / "exec-9b363acb-a5c5-4ed9-91d1-c91bd62185a0.png",
    "base_crimson.png": GEN / "exec-d3269856-b505-4ce7-8129-62f3a86d27e2.png",
}

ITEMS = {
    # filename: (source, target width, target height, center x, top y)
    "acc_beads.png": (GEN / "exec-e57f0617-a978-4366-a634-1dce9ba63eb8.png", 188, 158, 512, 470),
    "acc_glasses.png": (GEN / "exec-51275054-74b4-4241-a2db-5111166357dd.png", 258, 90, 512, 315),
    "seat_lotus.png": (GEN / "exec-fc45db66-eefe-4272-8f3c-0db7492d1184.png", 620, 210, 512, 804),
    "halo_ring.png": (GEN / "exec-e98c2875-2f0a-4243-805f-b7bf37b4fc04.png", 560, 560, 512, 20),
}

HEAD_ITEMS = {
    # Full-head replacements use the approved base face plus a fitted generated item.
    # filename: (transparent item source, target width, target height, center x, top y)
    "head_nabal.png": (GEN / "exec-9e2cb34b-f9c7-4b3c-86e8-9c8b9ab3f056.png", 420, 240, 512, 40),
    "head_bamboo.png": (GEN / "exec-c40e83a9-2893-499e-b1b2-4417ca7d3e0c.png", 500, 190, 512, 40),
    "head_straw.png": (GEN / "exec-ff31a338-468f-4137-82da-830ff200afed.png", 520, 170, 512, 40),
}


def alpha_bbox(image: Image.Image, threshold: int = 2):
    alpha = image.getchannel("A")
    return alpha.point(lambda value: 255 if value >= threshold else 0).getbbox()


def fit_to_base_bbox(image: Image.Image, target_bbox):
    source_bbox = alpha_bbox(image)
    subject = image.crop(source_bbox)
    width = target_bbox[2] - target_bbox[0]
    height = target_bbox[3] - target_bbox[1]
    subject = subject.resize((width, height), Image.Resampling.LANCZOS)
    canvas = Image.new("RGBA", (1024, 1024), (0, 0, 0, 0))
    canvas.alpha_composite(subject, (target_bbox[0], target_bbox[1]))
    return canvas


def make_cloth_mask(base: Image.Image, recolored: Image.Image, kind: str):
    def binary(channel, predicate):
        return channel.point(lambda value: 255 if predicate(value) else 0)

    diff_channels = ImageChops.difference(base.convert("RGB"), recolored.convert("RGB")).split()
    diff = ImageChops.lighter(ImageChops.lighter(diff_channels[0], diff_channels[1]), diff_channels[2])
    base_h, base_s, base_v = base.convert("HSV").split()
    new_h, new_s, new_v = recolored.convert("HSV").split()

    common = Image.new("L", (1024, 1024), 0)
    common.paste(255, (0, 470, 1024, 1024))
    for channel_mask in (
        binary(base.getchannel("A"), lambda value: value >= 2),
        binary(recolored.getchannel("A"), lambda value: value >= 2),
        binary(diff, lambda value: value >= 22),
        binary(base_s, lambda value: value >= 105),
    ):
        common = ImageChops.multiply(common, channel_mask)

    if kind == "base_temple.png":
        target_color = ImageChops.multiply(
            binary(new_s, lambda value: value <= 125),
            binary(new_v, lambda value: value <= 185),
        )
    elif kind == "base_ash.png":
        target_color = ImageChops.multiply(
            binary(new_s, lambda value: value <= 82),
            binary(new_v, lambda value: value <= 235),
        )
    else:
        red_hue = binary(new_h, lambda value: value <= 14 or value >= 245)
        target_color = ImageChops.multiply(
            red_hue,
            binary(new_s, lambda value: value >= 125),
        )

    mask = ImageChops.multiply(common, target_color)
    mask = mask.filter(ImageFilter.MaxFilter(5)).filter(ImageFilter.MinFilter(5))
    mask = mask.filter(ImageFilter.GaussianBlur(0.7))
    mask.paste(0, (0, 0, 1024, 470))
    return mask


def build_base_variants():
    base = Image.open(BASE).convert("RGBA")
    target_bbox = alpha_bbox(base)
    for name, source in BASE_VARIANTS.items():
        generated = Image.open(source).convert("RGBA")
        aligned = fit_to_base_bbox(generated, target_bbox)
        mask = make_cloth_mask(base, aligned, name)
        result = Image.composite(aligned, base, mask)
        result.putalpha(base.getchannel("A"))
        result.save(OUT / name, optimize=True)


def build_items():
    for name, (source, width, height, center_x, top_y) in ITEMS.items():
        generated = Image.open(source).convert("RGBA")
        subject = generated.crop(alpha_bbox(generated))
        subject = subject.resize((width, height), Image.Resampling.LANCZOS)
        canvas = Image.new("RGBA", (1024, 1024), (0, 0, 0, 0))
        canvas.alpha_composite(subject, (center_x - width // 2, top_y))
        canvas.save(OUT / name, optimize=True)


def build_heads():
    base = Image.open(BASE).convert("RGBA")
    base_alpha = base.getchannel("A")
    base_alpha.paste(0, (0, 480, 1024, 1024))
    base.putalpha(base_alpha)

    for name, (source, width, height, center_x, top_y) in HEAD_ITEMS.items():
        generated = Image.open(source).convert("RGBA")
        subject = generated.crop(alpha_bbox(generated))
        subject = subject.resize((width, height), Image.Resampling.LANCZOS)
        result = base.copy()
        result.alpha_composite(subject, (center_x - width // 2, top_y))
        final_alpha = result.getchannel("A")
        final_alpha.paste(0, (0, 480, 1024, 1024))
        result.putalpha(final_alpha)
        result.save(OUT / name, optimize=True)


if __name__ == "__main__":
    build_base_variants()
    build_items()
    build_heads()
