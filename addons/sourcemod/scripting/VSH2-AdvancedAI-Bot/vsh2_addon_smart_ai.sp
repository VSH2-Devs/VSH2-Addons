#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <tf2_stocks>
#include <vsh2_smart_ai>


public Plugin myinfo = {
	name        = "VSH2 Smart AI Bosses addon",
	author      = "Nergal/Assyrian",
	description = "",
	version     = "1.0",
	url         = "https://github.com/VSH2-Devs/VSH2-Addons"
};

/// look into: 'https://github.com/rcbotCheeseh/rcbot2/tree/master/utils/RCBot2_meta'
/// https://developer.valvesoftware.com/wiki/AI_Programming_Overview


enum struct VSH2AdvancedAI {
	PrivateForward OnAIAct;
	ArrayList trees;
	StringMap scores;
}

VSH2AdvancedAI g_vsh2ai;


public void OnLibraryAdded(const char[] name) {
	if( StrEqual(name, "VSH2") ) {
		LoadVSH2Hooks();
	}
}

public void LoadVSH2Hooks() {
	g_vsh2ai.OnAIAct = new PrivateForward(ET_Event, Param_Array, Param_Cell);
	g_vsh2ai.scores = new StringMap();
	
	if( !VSH2_HookEx(OnRoundStart, AIBotOnRoundStart) )
		LogError("Error Hooking OnRoundStart forward for Smart AI addon.");
		
	if( !VSH2_HookEx(OnBossThinkPost, AIBotBossPostThink) )
		LogError("Error Hooking OnBossThinkPost forward for Smart AI addon.");
}

public void AIBotOnRoundStart(const VSH2Player[] bosses, const int boss_count, const VSH2Player[] red_players, const int red_count)
{
	int boss_amount = VSH2_GetMaxBosses() + 1;
	if( g_vsh2ai.trees==null ) {
		g_vsh2ai.trees = new ArrayList(sizeof(AIActNode), boss_amount);
	} else if( g_vsh2ai.trees.Length < boss_amount ) {
		/// if custom bosses were late-loaded, update the tree array.
		g_vsh2ai.trees.Resize(boss_amount);
	}
	
	
}

public void AIBotBossPostThink(const VSH2Player player)
{
	if( !IsFakeClient(player.index) )
		return;
	
	int boss_type = player.GetPropInt("iBossType");
	AIActNode root; g_vsh2ai.trees.GetArray(boss_type, root);
	root.curr_state = ExecAINode(root, g_vsh2ai.scores);
}

AIActState ExecAINode(AIActNode node, StringMap scores)
{
	switch( node.tag ) {
		case AINode_Invalid: {
			int kids = node.components.Length;
			for( int i; i<kids; i++ ) {
				AIActNode child; node.components.GetArray(i, child);
				node.curr_state = FwdCall_OnAIAct(child, scores);
				RunAINode(child, scores);
			}
		}
		case AINode_Conditional: {
			return FwdCall_OnAIAct(node, scores);
			/**
			 * 'm_Condition' is a function pointer.
			if( !m_Condition )
				return BehaviorState::FAILIURE;

			switch( m_Condition() ) {
				case true:
					return BehaviorState::SUCCESS;
				case false:
					return BehaviorState::FAILIURE;
			}
			*/
		}
		case AINode_Selector: {
			/**
			for(auto child : m_ChildrenBehaviours)
			{
				m_CurrentState = child->Execute();
				switch (m_CurrentState)
				{
				case BehaviorState::FAILIURE:
					continue;
				case BehaviorState::SUCCESS:
					return m_CurrentState;
				case BehaviorState::RUNNING:
					return m_CurrentState;
				}
			}
			return m_CurrentState = BehaviorState::FAILIURE;
			 */
		}
		case AINode_Sequence: {
			/**
			for(auto child : m_ChildrenBehaviours)
			{
				m_CurrentState = child->Execute();
				switch (m_CurrentState)
				{
				case BehaviorState::FAILIURE:
					return m_CurrentState;
				case BehaviorState::SUCCESS:
					continue;
				case BehaviorState::RUNNING:
					return m_CurrentState;
				}
			}
			return m_CurrentState = BehaviorState::SUCCESS;
			 */
		}
		case AINode_PartSequence: {
			/**
			while (m_CurrentBehaviorIdx < m_ChildrenBehaviours.size())
			{
				m_CurrentState = m_ChildrenBehaviours[m_CurrentBehaviorIdx]->Execute();
				switch (m_CurrentState)
				{
				case BehaviorState::FAILIURE:
					m_CurrentBehaviorIdx = 0;
					return m_CurrentState;
				case BehaviorState::SUCCESS:
					++m_CurrentBehaviorIdx;
					return m_CurrentState = BehaviorState::RUNNING; //Force continue running
				case BehaviorState::RUNNING:
					return m_CurrentState;
				}
			}
			m_CurrentBehaviorIdx = 0;
			return m_CurrentState = BehaviorState::SUCCESS;
			 */
		}
		case AINode_Action: {
			/**
			if (!m_Action)
				return BehaviorState::FAILIURE;
			return m_CurrentState = m_Action();
			 */
		}
	}
}


AIActState FwdCall_OnAIAct(AIActNode node, StringMap scores)
{
	AIActState res;
	if( g_vsh2ai.OnAIAct != null ) {
		Call_StartForward(g_vsh2ai.OnAIAct);
		Call_PushArrayEx(node, sizeof(node), SM_PARAM_COPYBACK);
		Call_PushCell(scores);
		Call_Finish(res);
	}
	return res;
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNative("VSH2_HookAIActFunc", Native_HookAIFunc);
	CreateNative("VSH2_UnhookAIActFunc", Native_UnhookAIFunc);
}

public any Native_HookAIFunc(Handle plugin, int params)
{
	Function func = GetNativeFunction(1);
	if( g_vsh2ai.OnAIAct != null ) {
		return g_vsh2ai.OnAIAct.AddFunction(plugin, func);
	}
	return false;
}

public any Native_UnhookAIFunc(Handle plugin, int params)
{
	Function func = GetNativeFunction(1);
	if( g_vsh2ai.OnAIAct != null ) {
		return g_vsh2ai.OnAIAct.RemoveFunction(plugin, func);
	}
	return false;
}
