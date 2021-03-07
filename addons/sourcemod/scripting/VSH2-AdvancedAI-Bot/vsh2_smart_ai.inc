#if defined _vsh2_smart_ai_included
	#endinput
#endif
#define _vsh2_smart_ai_included


#include <sourcemod>
#include <vsh2>

/**
 * Bot will work with ALL of the boss abilities.
 * Won't auto-rage but rage strategically.
 * Actions defined from Utility/Scorer system.
 * 
 */

enum AIActState {
	ActState_Fail,
	ActState_Ok,
	ActState_Exec
};

enum AINodeType {
	AINode_Invalid,
	AINode_Conditional,
	AINode_Selector,
	AINode_Sequence,
	AINode_PartSequence,
	AINode_Action,
};


enum struct AIActNode {
	ArrayList  components;     /// []AIActNode
	int        curr_component;
	AIActState curr_state;
	AINodeType tag;
}

stock any[] MakeAINode(AINodeType node_type, int default_component=0) {
	AIActNode node;
	node.components = new ArrayList(sizeof(AIActNode));
	node.tag = node_type;
	node.curr_component = default_component;
	return node;
}

stock int InsertAINode(AIActNode owner, AIActNode other) {
	return owner.components.PushArray(other);
}

stock void DestroyAITree(AIActNode root) {
	int num_components = root.components.Length;
	for( int i; i<num_components; i++ ) {
		AIActNode n; root.components.GetArray(i, n);
		DestroyAITree(n);
	}
	delete root.components;
}


typedef AIActFunc = function AIActState (AIActNode node, StringMap scores);

native bool VSH2_HookAIActFunc(AIActFunc hook);
native bool VSH2_UnhookAIActFunc(AIActFunc hook);



public SharedPlugin __pl_vsh2_smart_ai = {
	name = "VSH2 Smart AI",
	file = "vsh2_addon_smart_ai.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_vsh2_smart_ai_SetNTVOptional()
{
	MarkNativeAsOptional("VSH2_HookAIActFunc");
	MarkNativeAsOptional("VSH2_UnhookAIActFunc");
}
#endif