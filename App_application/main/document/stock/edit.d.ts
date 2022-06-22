
export interface TItem extends IElement {
	Id: number;
	Name: string;
}

export interface TRow extends IArrayElement {
	Id: number;
	Qty: number;
	Price: number;
	Sum: number;
	Item: TItem;
}

declare type TRows = IElementArray<TRow>;

export interface TAgent extends IElement {
	Id: number;
	Name: string;
	Code: string;
}

export interface TDocument extends IElement {
	Id: number;
	Date: Date;
	Sum: number;
	Rows: TRows;
	No: string;
	Done: boolean;
	Memo: string;
	Agent: TAgent;
}


export interface TParam extends IElement {
	Kind: string;
}

export interface TRoot extends IRoot {
	Document: TDocument;
	Params: TParam;
}
