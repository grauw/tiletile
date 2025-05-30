// png-js v1.0.0
declare module "png-js" {
	type PathOrFileDescriptor = import("fs").PathOrFileDescriptor;

	export default class PNG {
		width: number;
		height: number;
		bits: number;
		colorType: number;
		compressionMethod: number;
		filterMethod: number;
		interlaceMethod: number;
		colors: number;
		hasAlphaChannel: boolean;
		pixelBitlength: number;
		colorSpace?: "DeviceGray" | "DeviceRGB";
		data: ArrayLike<number>;
		palette: number[];
		imgData: Buffer;
		transparency: {} | { indexed: number[] } | { grayscale: number } | { rgb: number[] };
		text: Partial<Record<string, string>>;

		constructor(buffer: ArrayLike<number>);

		decode(fn: (pixels: Buffer) => void): void;
		decodePalette(): Buffer;
		decodePixels(fn: (pixels: Buffer) => void): Uint8Array;
		copyToImageData(imageData: ArrayLike<number>, pixels: ArrayLike<number>): void;

		static decode(path: PathOrFileDescriptor, fn: (pixels: Buffer) => void): void;
		static load(path: PathOrFileDescriptor): PNG;
	}
}
