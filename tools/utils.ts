export function toAsmHex(value: number) {
	const hex = value.toString(16).toUpperCase();
	return hex.charCodeAt(0) > 64 ? `0${hex}H` : `${hex}H`;
}
