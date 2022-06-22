

export interface TRow extends IArrayElement {
	Qty: number;
	Price: number;
	Sum: number;
}

declare type TRows = IElementArray<TRow>;

export interface TDocument extends IElement {
	Id: Number;
	Date: Date;
	Rows: TRows;
}

export interface TRoot extends IRoot {
	Document: TDocument;
}