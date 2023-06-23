import re


def parse_os(os_version: list[str]) -> str:
    if "Mint" in os_version:
        return f"{os_version[0]} {os_version[1]}"

    if "NAME=" in os_version[0]:
        return os_version[0].split("=")[1].strip('"')

    return os_version[0].strip('"')


def parse_os_version(vals: list[str]) -> str:
    return next(
        (
            s
            for s in vals
            if (s and s[0].isdigit() or s == "XP" or s == "Vista")
            and s != "64"
            and s != "32"
        ),
        "N/A",
    )


def parse_gpu_sub_brand(vga: list[str]) -> str | None:
    if len(vga) <= 3:
        return None
    try:
        return None if vga[1][0].isdigit() else vga[1].lower()
    except IndexError:
        return None


def parse_ram_capacity(ram: str) -> float:
    if "less" in ram.lower():
        return round(float(ram.strip().split(" ")[-2]), 2)

    if ram.lower().startswith("above"):
        return round(float(ram.strip().split(" ")[1]) * 1024, 2)

    if ram.lower().endswith("above"):
        return round(float(ram.strip().split(" ")[0]) * 1024, 2)

    if "more" in ram.lower():
        return 32 * 1024

    if "gb" in ram.lower():
        return round(float(ram.strip().split(" ")[0]) * 1024, 2)

    return round(float(ram.strip().split(" ")[0]), 2)


def clean_os_version(
    os_version: str,
    percentage: float,
) -> dict[str, str | float]:
    cleaned: dict[str, str | float] = {}

    cleaned["os"] = parse_os(os_version.split(" "))
    cleaned["version"] = parse_os_version(os_version.split(" "))
    cleaned["architecture"] = "64" if "64" in os_version else "32"
    cleaned["percentage"] = round(percentage, 2)

    return cleaned


def clean_windows_version(
    windows_version: str,
    percentage: float,
) -> dict[str, str | float]:
    pattern = (
        r"(\bXP|\b98|\b95|\b2000|\b2003|\bMe|\b7|\bVista)\s?(SP \d|\(Build \d+\))?"
    )
    cleaned: dict[str, str | float] = {}

    cleaned["os"] = "Windows"
    cleaned["version"] = (
        os.group() if (os := re.search(pattern, windows_version)) else "N/A"
    )
    cleaned["architecture"] = "64" if "64" in windows_version else "32"
    cleaned["percentage"] = round(percentage, 2)

    return cleaned


def clean_vga(vga: str, percentage: float) -> dict[str, str | float | None]:
    cleaned: dict[str, str | float | None] = {}
    test = vga.split(" ")

    cleaned["name"] = "".join(test[0].split("(")[0]).lower()
    cleaned["sub_brand"] = parse_gpu_sub_brand(test)
    cleaned["model"] = " ".join(test[2::])
    cleaned["percentage"] = round(percentage, 2)

    return cleaned


def clean_ram(ram: str, percentage: float) -> dict[str, str | float | None]:
    cleaned: dict[str, str | float | None] = {}

    cleaned["min_capacity"] = parse_ram_capacity(ram.split("to")[0])
    cleaned["max_capacity"] = (
        parse_ram_capacity(ram_config[1])
        if (len(ram_config := ram.split("to")) > 1)
        else cleaned["min_capacity"] * 2
    )
    cleaned["percentage"] = round(percentage, 2)

    return cleaned


def clean_cores(cores: str, percentage: float) -> dict[str, str | float | None]:
    cleaned: dict[str, str | float | None] = {}

    cleaned["cpu_count"] = (
        int(cores.split("cpu")[0]) if "unspecified" not in cores.lower() else 0
    )
    cleaned["percentage"] = round(percentage, 2)

    return cleaned
